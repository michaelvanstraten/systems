{ config, ... }:
{
  sops.secrets."de-ber-wg-001.conf" = {
    sopsFile = ./de-ber-wg-001.conf;
    format = "binary";
  };

  sops.secrets."proxy/username".sopsFile = ./secrets.yaml;
  sops.secrets."proxy/password".sopsFile = ./secrets.yaml;

  sops.templates."soax-auth".content = ''
    ${config.sops.placeholder."proxy/username"} ${config.sops.placeholder."proxy/password"}
  '';

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
      "/run/secrets/soax-auth" = {
        hostPath = config.sops.templates."soax-auth".path;
        isReadOnly = true;
      };
    };

    config =
      { pkgs, ... }:
      let
        gostConfig = (pkgs.formats.yaml { }).generate "gost.yaml" {
          services = [
            {
              name = "socks5-mullvad";
              addr = ":1080";
              handler = {
                type = "socks5";
                chain = "chain-mullvad";
              };
              listener.type = "tcp";
            }
            {
              name = "socks5-soax";
              addr = ":1081";
              handler = {
                type = "socks5";
                chain = "chain-soax";
              };
              listener.type = "tcp";
            }
            {
              name = "dns-proxy";
              addr = "10.100.0.4:53";
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
              name = "chain-mullvad";
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
            {
              name = "chain-soax";
              hops = [
                {
                  name = "hop-0";
                  nodes = [
                    {
                      name = "soax";
                      addr = "proxy.soax.com:5000";
                      connector = {
                        type = "socks5";
                        auth.file = "/run/credentials/gost.service/soax-auth";
                      };
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

        networking = {
          useNetworkd = true;
          useHostResolvConf = false;
          nameservers = [ "10.64.0.1" ];

          wg-quick.interfaces."de-ber-wg-001".configFile = "/run/secrets/de-ber-wg-001.conf";

          firewall = {
            allowedTCPPorts = [
              53
              1080
              1081
            ];
            allowedUDPPorts = [ 53 ];
          };
        };

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.4/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        systemd.services.gost = {
          description = "GOST SOCKS5 (Mullvad + SOAX) + DNS proxy";
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
            LoadCredential = "soax-auth:/run/secrets/soax-auth";
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          };
        };
      };
  };
}
