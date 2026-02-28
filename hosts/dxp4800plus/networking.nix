{ ... }:
{
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
      };
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "br-containers" ];
    externalInterface = "enp6s0";
  };

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain forward {
          type filter hook forward priority 0; policy drop;

          # Allow established/related connections everywhere
          ct state established,related accept

          # Allow containers to reach the internet (bridge -> WAN)
          iifname "br-containers" oifname "enp6s0" accept

          # ---- East/West Policy (container <-> container) ----

          # Allow newt (10.100.0.2) -> jellyfin (10.100.0.3)
          iifname "br-containers" oifname "br-containers" ip saddr 10.100.0.2 ip daddr 10.100.0.3 accept

          # Default: block any other container-to-container traffic on the bridge
          iifname "br-containers" oifname "br-containers" drop
        }
      }
    '';
  };
}
