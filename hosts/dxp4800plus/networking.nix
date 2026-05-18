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
      };

      "30-br-vms" = {
        matchConfig.Name = "br-vms";
        address = [ "10.101.0.1/24" ];
        bridgeConfig = { };
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
    ruleset = ''
      table inet filter {
        chain forward {
          type filter hook forward priority 0; policy drop;

          # Allow established/related connections everywhere
          ct state established,related accept

          # ---- Egress: bridges -> WAN ----

          # Allow containers to reach the internet
          iifname "br-containers" oifname "enp6s0" accept

          # Allow VMs to reach the internet
          iifname "br-vms" oifname "enp6s0" accept

          # ---- East/West Policy (container <-> container) ----

          # Allow newt (10.100.0.2) -> jellyfin (10.100.0.3)
          iifname "br-containers" oifname "br-containers" ip saddr 10.100.0.2 ip daddr 10.100.0.3 accept

          # Allow newt (10.100.0.2) -> paperless (10.100.0.6)
          iifname "br-containers" oifname "br-containers" ip saddr 10.100.0.2 ip daddr 10.100.0.6 accept

          # Allow newt (10.100.0.2) -> nextcloud (10.100.0.8)
          iifname "br-containers" oifname "br-containers" ip saddr 10.100.0.2 ip daddr 10.100.0.8 accept

          # ---- Cross-bridge (container -> VM) ----

          # Allow newt (10.100.0.2) -> buildkit microvm (10.101.0.9) on the gRPC port
          iifname "br-containers" oifname "br-vms" ip saddr 10.100.0.2 ip daddr 10.101.0.9 tcp dport 1234 accept

          # ---- Default deny: bridge-local & cross-bridge ----

          # Block any other container-to-container traffic on the bridge
          iifname "br-containers" oifname "br-containers" drop

          # Block any other VM-to-VM traffic on the bridge
          iifname "br-vms" oifname "br-vms" drop

          # Block any other cross-bridge traffic in both directions
          iifname "br-containers" oifname "br-vms" drop
          iifname "br-vms" oifname "br-containers" drop
        }
      }
    '';
  };
}
