{ config, lib, ... }:
let
  inherit (lib) head splitString;

  servarrIp = head (splitString "/" config.containers.servarr.localAddress);
  containersSubnet = "10.100.0.0/24";

  interface = "airvpn";
  table = 100;
  forwardedPort = 50475;
in
{
  sops.secrets."airvpn/private-key" = { };
  sops.secrets."airvpn/preshared-key" = { };

  networking.wireguard.interfaces.${interface} = {
    ips = [
      "10.178.196.41/32"
      "fd7d:76ee:e68f:a993:298e:f780:656f:cefc/128"
    ];
    mtu = 1420;
    privateKeyFile = config.sops.secrets."airvpn/private-key".path;

    allowedIPsAsRoutes = false;

    peers = [
      {
        publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
        presharedKeyFile = config.sops.secrets."airvpn/preshared-key".path;
        endpoint = "de3.vpn.airdns.org:1637";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        persistentKeepalive = 15;
      }
    ];

    postSetup = ''
      ip route replace default dev ${interface} table ${toString table}
    '';

    postShutdown = ''
      ip route del default dev ${interface} table ${toString table} 2>/dev/null || true
    '';
  };

  systemd.network.networks."20-br-containers" = {
    routingPolicyRules = [
      {
        From = servarrIp;
        Table = table;
        Priority = 1000;
      }
    ];
    routes = [
      {
        Destination = containersSubnet;
        Scope = "link";
        Table = table;
      }
    ];
  };

  systemd.network.config.networkConfig = {
    ManageForeignRoutes = false;
    ManageForeignRoutingPolicyRules = false;
  };

  networking.firewall.checkReversePath = "loose";

  networking.nftables.tables."airvpn-mss" = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority mangle; policy accept;
        oifname "${interface}" tcp flags syn tcp option maxseg size set rt mtu
        iifname "${interface}" tcp flags syn tcp option maxseg size set rt mtu
      }
    '';
  };

  networking.nftables.tables."airvpn-nat" = {
    family = "ip";
    content = ''
      chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;

        # AirVPN forwarded port -> qBittorrent in the servarr container.
        iifname "${interface}" tcp dport ${toString forwardedPort} dnat to ${servarrIp}
        iifname "${interface}" udp dport ${toString forwardedPort} dnat to ${servarrIp}
      }

      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        # Masquerade servarr behind the tunnel address on the way out.
        oifname "${interface}" ip saddr ${containersSubnet} masquerade
      }
    '';
  };
}
