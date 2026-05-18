{ config, ... }:
{
  sops.secrets."de-ber-wg-001.conf" = {
    sopsFile = ./de-ber-wg-001.conf;
    format = "binary";
  };

  containers.proxy-sidecar = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.4/24";

    bindMounts = {
      "/run/secrets/de-ber-wg-001.conf" = {
        hostPath = config.sops.secrets."de-ber-wg-001.conf".path;
        isReadOnly = true;
      };
    };

    config =
      { pkgs, ... }:
      let
        gostConfig = (pkgs.formats.yaml { }).generate "gost.yaml" {
          services = [
            {
              name = "socks5-proxy";
              addr = ":1080";
              handler = {
                type = "socks5";
                chain = "chain-0";
              };
              listener.type = "tcp";
            }
            {
              name = "dns-proxy";
              addr = ":53";
              handler.type = "dns";
              listener = {
                type = "dns";
                metadata.mode = "udp";
              };
              forwarder.nodes = [
                {
                  name = "mullvad-dns";
                  addr = "tcp://10.64.0.1:53";
                }
              ];
            }
          ];
          chains = [
            {
              name = "chain-0";
              hops = [
                {
                  name = "hop-0";
                  nodes = [
                    {
                      name = "mullvad";
                      addr = "10.64.0.1:1080";
                      connector.type = "socks5";
                      dialer.type = "tcp";
                    }
                  ];
                }
              ];
            }
          ];
        };
      in
      {
        system.stateVersion = "26.05";

        networking.useNetworkd = true;
        networking.useHostResolvConf = false;
        # Mullvad DNS is only reachable once WireGuard is up; resolved picks
        # this up from the networkd DNS= field so that it becomes available
        # as soon as the wg-quick service brings the tunnel online.
        networking.nameservers = [ "10.64.0.1" ];

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.4/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        networking.wg-quick.interfaces."de-ber-wg-001".configFile = "/run/secrets/de-ber-wg-001.conf";

        networking.firewall.allowedTCPPorts = [
          53
          1080
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        systemd.services.gost = {
          description = "GOST SOCKS5 + DNS proxy forwarding to Mullvad";
          after = [
            "network.target"
            "wg-quick-de-ber-wg-001.service"
          ];
          wants = [ "wg-quick-de-ber-wg-001.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.gost}/bin/gost -C ${gostConfig}";
            Restart = "on-failure";
            RestartSec = "5s";
            DynamicUser = true;
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          };
        };
      };
  };
}
