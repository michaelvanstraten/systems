{ config, lib, ... }:
let
  inherit (lib) head splitString;

  containerIp = name: head (splitString "/" config.containers.${name}.localAddress);
in
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

          # ---- Servarr container isolation ----

          # Allow servarr -> proxy-sidecar on SOCKS port 1080 and DNS
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "servarr"} ip daddr ${containerIp "proxy-sidecar"} tcp dport { 53, 1080, 1081 } accept
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "servarr"} ip daddr ${containerIp "proxy-sidecar"} udp dport 53 accept

          # Block all other outbound traffic from qbittorrent (internet and east/west)
          iifname "br-containers" ip saddr ${containerIp "servarr"} drop

          # ---- Egress: bridges -> WAN ----

          # Allow containers to reach the internet
          iifname "br-containers" oifname "enp6s0" accept

          # Allow VMs to reach the internet
          iifname "br-vms" oifname "enp6s0" accept

          # ---- East/West Policy (container <-> container) ----

          # Allow newt -> jellyfin
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "jellyfin"} accept

          # Allow newt -> servarr
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "servarr"} accept

          # Allow newt -> paperless
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "paperless"} accept

          # Allow newt -> samba
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "samba"} accept

          # Allow newt -> nextcloud
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "nextcloud"} accept

          # Allow newt -> monitoring
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "newt"} ip daddr ${containerIp "monitoring"} accept

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
