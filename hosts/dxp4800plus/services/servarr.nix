{ config, lib, ... }:
let
  containerIp = "10.100.0.5";
  proxyIp = "10.100.0.4";
  proxyPort = 1080;
  cfg = config.containers.servarr.config;

  proxyUrl = "socks5://${proxyIp}:${toString proxyPort}";

  # Residential exit (SOAX) for traffic that gets crushed by Cloudflare on
  # Mullvad IPs -- currently only FlareSolverr.
  residentialProxyPort = 1081;
  residentialProxyUrl = "socks5://${proxyIp}:${toString residentialProxyPort}";

  proxyEnv = {
    ALL_PROXY = proxyUrl;
    NO_PROXY = "localhost,127.0.0.1,10.100.0.0/24";
  };
in
{
  services.newt.blueprint = {
    private-resources = {
      qbittorrent = {
        name = "qBittorrent";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.qbittorrent.webuiPort;
        full-domain = "qbittorrent.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
      sonarr = {
        name = "Sonarr";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.sonarr.settings.server.port;
        full-domain = "sonarr.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
      radarr = {
        name = "Radarr";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.radarr.settings.server.port;
        full-domain = "radarr.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
      prowlarr = {
        name = "Prowlarr";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.prowlarr.settings.server.port;
        full-domain = "prowlarr.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.servarr = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "${containerIp}/24";

    config =
      { pkgs, ... }:
      let
        mkAuthEnv =
          app:
          pkgs.writeText "${app}-auth.env" ''
            ${lib.toUpper app}__AUTH__METHOD=External
            ${lib.toUpper app}__AUTH__REQUIRED=DisabledForLocalAddresses
          '';
      in
      {
        services = {
          qbittorrent = {
            enable = true;
            openFirewall = true;
            serverConfig = {
              Preferences = {
                Connection = {
                  Proxy = {
                    Type = 2;
                    IP = proxyIp;
                    Port = proxyPort;
                    AuthEnabled = false;
                    ProxyPeerConnections = true;
                    RSS = true;
                    Misc = true;
                    BitTorrent = true;
                  };
                };
              };
            };
          };
          sonarr = {
            enable = true;
            openFirewall = true;
            environmentFiles = [ (mkAuthEnv "sonarr") ];
          };
          radarr = {
            enable = true;
            openFirewall = true;
            environmentFiles = [ (mkAuthEnv "radarr") ];
          };
          prowlarr = {
            enable = true;
            openFirewall = true;
            environmentFiles = [ (mkAuthEnv "prowlarr") ];
          };
          flaresolverr = {
            enable = true;
          };
        };

        systemd.services =
          lib.genAttrs [ "sonarr" "radarr" "prowlarr" ] (_: {
            environment = proxyEnv;
          })
          // {
            flaresolverr.environment.PROXY_URL = residentialProxyUrl;
          };

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "${containerIp}/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        networking = {
          useNetworkd = true;
          useHostResolvConf = false;
          nameservers = [ proxyIp ];
        };

        system.stateVersion = "26.05";
      };
  };
}
