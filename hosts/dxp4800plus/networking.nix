{ config, lib, ... }:
let
  inherit (lib) head splitString;
  containerIp = name: head (splitString "/" config.containers.${name}.localAddress);
  servarrIp = containerIp "servarr";
  proxyIp = containerIp "proxy-sidecar";
  residentialProxyPort = 1080;
  vpnInterface = "airvpn";
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
        linkConfig.RequiredForOnline = false;
      };

      "30-br-vms" = {
        matchConfig.Name = "br-vms";
        address = [ "10.101.0.1/24" ];
        bridgeConfig = { };
        linkConfig.RequiredForOnline = false;
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

          # ---- Servarr container isolation  ----

          # Allow servarr -> residential SOCKS5 proxy on the sidecar
          iifname "br-containers" oifname "br-containers" ip saddr ${servarrIp} ip daddr ${proxyIp} tcp dport ${toString residentialProxyPort} accept

          # Allow servarr -> internet, but ONLY through the WireGuard tunnel.
          iifname "br-containers" oifname "${vpnInterface}" ip saddr ${servarrIp} accept

          # Allow server -> jellyfin
          iifname "br-containers" oifname "br-containers" ip saddr ${containerIp "servarr"} ip daddr ${containerIp "jellyfin"} accept

          # Allow AirVPN's forwarded port to qBittorrent.
          iifname "${vpnInterface}" oifname "br-containers" ct status dnat accept

          # Fail closed: drop anything else leaving the servarr container
          iifname "br-containers" ip saddr ${servarrIp} drop

          # ---- Egress: bridges -> WAN ----

          # Allow containers to reach the internet
          iifname "br-containers" oifname "enp6s0" accept

          # Allow VMs to reach the internet
          iifname "br-vms" oifname "enp6s0" accept

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
