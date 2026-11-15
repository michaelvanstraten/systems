{ config, lib, ... }:
let
  inherit (lib) head splitString;

  cfg = config.networking.airvpn;

  containerIp = name: head (splitString "/" config.containers.${name}.localAddress);
  containersSubnet = "10.100.0.0/24";

  # Renders a list of nftables rules per client, indented to sit inside a chain.
  clientRules = f: lib.concatStringsSep "\n  " (lib.concatLists (lib.mapAttrsToList f cfg.clients));
in
{
  options.networking.airvpn = {
    interface = lib.mkOption {
      type = lib.types.str;
      default = "airvpn";
      description = "WireGuard interface carrying the tunnel.";
    };

    dns = lib.mkOption {
      type = lib.types.str;
      default = "10.128.0.1";
      description = "Resolver that is only reachable through the tunnel.";
    };

    clients = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            forwardedPort = lib.mkOption {
              type = lib.types.port;
              description = ''
                Port AirVPN forwards to this account. Arriving traffic is DNATed
                to the container, which listens on the same port.
              '';
            };

            extraEgressRules = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                nftables rules accepting traffic from the container to
                destinations other than the tunnel. Everything else is dropped.
              '';
            };
          };
        }
      );
      default = { };
      description = ''
        Containers, by name, whose traffic may only leave through the tunnel.
      '';
    };

    routingTable = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Routing table holding the tunnel's default route.";
    };
  };

  config = {
    assertions = [
      {
        assertion = lib.allUnique (lib.mapAttrsToList (_: client: client.forwardedPort) cfg.clients);
        message = "networking.airvpn.clients must not share a forwardedPort";
      }
    ];

    sops.secrets."airvpn/private-key" = { };
    sops.secrets."airvpn/preshared-key" = { };

    networking.wireguard.interfaces.${cfg.interface} = {
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
        ip route replace default dev ${cfg.interface} table ${toString cfg.routingTable}
      '';

      postShutdown = ''
        ip route del default dev ${cfg.interface} table ${toString cfg.routingTable} 2>/dev/null || true
      '';
    };

    systemd.network.networks."20-br-containers" = {
      routingPolicyRules = lib.concatMap (name: [
        {
          From = containerIp name;
          Table = cfg.routingTable;
          Priority = 1000;
        }
        {
          From = containerIp name;
          Type = "unreachable";
          Priority = 1001;
        }
      ]) (lib.attrNames cfg.clients);
      routes = [
        {
          Destination = containersSubnet;
          Scope = "link";
          Table = cfg.routingTable;
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
          oifname "${cfg.interface}" tcp flags syn tcp option maxseg size set rt mtu
          iifname "${cfg.interface}" tcp flags syn tcp option maxseg size set rt mtu
        }
      '';
    };

    networking.nftables.tables."airvpn-nat" = {
      family = "ip";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;

          ${clientRules (
            name: client: [
              ''iifname "${cfg.interface}" tcp dport ${toString client.forwardedPort} dnat to ${containerIp name}''
              ''iifname "${cfg.interface}" udp dport ${toString client.forwardedPort} dnat to ${containerIp name}''
            ]
          )}
        }

        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;

          ${clientRules (
            name: _: [ ''oifname "${cfg.interface}" ip saddr ${containerIp name} masquerade'' ]
          )}
        }
      '';
    };
  };
}
