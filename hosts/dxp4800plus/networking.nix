{ config, lib, ... }:
let
  inherit (lib) head splitString;
  containerIp = name: head (splitString "/" config.containers.${name}.localAddress);
  servarrIp = containerIp "servarr";
  proxyIp = containerIp "proxy-sidecar";
  jellyfinIp = containerIp "jellyfin";
  jellyfinPort = config.services.newt.blueprint.private-resources.jellyfin.destination-port;
  residentialProxyPort = 1080;
  vpnInterface = config.networking.airvpn.interface;
  bridgePort = name: "vb-${name}";
  servarrPort = bridgePort "servarr";
in
{
  assertions = [
    {
      assertion = config.containers.servarr.hostBridge == "br-containers";
      message = ''
        The servarr anti-spoof filter hooks the bridge family on ${servarrPort} and
        silently stops applying unless the container is attached to br-containers.
      '';
    }
    {
      assertion = builtins.stringLength servarrPort <= 15;
      message = ''
        systemd-nspawn shortens host-side veth names longer than 15 characters, which
        would leave ${servarrPort} unmatched by the servarr anti-spoof filter.
      '';
    }
  ];

  networking.useDHCP = false;

  boot.kernelModules = [ "br_netfilter" ];

  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  systemd.network = {
    enable = true;

    netdevs = {
      "20-br-containers" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-containers";
        };
      };

      "30-br-vms" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-vms";
        };
      };
    };

    networks = {
      "10-enp6s0" = {
        matchConfig.Name = "enp6s0";
        networkConfig.DHCP = "yes";
      };

      "20-br-containers" = {
        matchConfig.Name = "br-containers";
        address = [ "10.100.0.1/24" ];
        bridgeConfig = { };
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          ConfigureWithoutCarrier = true;
          IgnoreCarrierLoss = true;
        };
      };

      "30-br-vms" = {
        matchConfig.Name = "br-vms";
        address = [ "10.101.0.1/24" ];
        bridgeConfig = { };
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          ConfigureWithoutCarrier = true;
          IgnoreCarrierLoss = true;
        };
      };
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [
      "br-containers"
      "br-vms"
    ];
    externalInterface = "enp6s0";
  };

  networking.nftables = {
    enable = true;
    tables."servarr-antispoof" = {
      family = "bridge";
      content = ''
        chain prerouting {
          type filter hook prerouting priority filter; policy accept;

          iifname "${servarrPort}" ip saddr ${servarrIp} accept
          iifname "${servarrPort}" arp saddr ip ${servarrIp} accept

          iifname "${servarrPort}" drop
        }
      '';
    };

    tables."filter" = {
      family = "inet";
      content = ''
        chain servarr-egress {
          oifname "${vpnInterface}" accept

          # Residential SOCKS5 proxy on the sidecar.
          ip daddr ${proxyIp} tcp dport ${toString residentialProxyPort} accept

          # Library refresh notifications to Jellyfin.
          ip daddr ${jellyfinIp} tcp dport ${toString jellyfinPort} accept

          drop
        }

        chain forward {
          type filter hook forward priority 0; policy drop;

          # ---- Servarr container isolation ----
          iifname "br-containers" ip saddr ${servarrIp} jump servarr-egress
          iifname "br-containers" meta nfproto ipv6 drop

          ct state established,related accept

          iifname "${vpnInterface}" oifname "br-containers" ip daddr ${servarrIp} ct status dnat accept

          # ---- Egress: bridges -> WAN ----

          iifname "br-containers" oifname "enp6s0" accept
          iifname "br-vms" oifname "enp6s0" accept
          iifname "tailscale0" oifname "enp6s0" accept

          # ---- Default deny: bridge-local & cross-bridge ----

          iifname "br-containers" oifname "br-containers" drop
          iifname "br-vms" oifname "br-vms" drop
          iifname "br-containers" oifname "br-vms" drop
          iifname "br-vms" oifname "br-containers" drop
        }
      '';
    };
  };
}
