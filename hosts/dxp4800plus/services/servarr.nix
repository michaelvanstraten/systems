{ config, lib, ... }:
let
  hostConfig = config;
  containerIp = "10.100.0.5";
  cfg = config.containers.servarr.config;
  vpn = config.networking.airvpn;
  mediaDir = "/srv/media";
  downloadDir = "${mediaDir}/downloads";
  mediaGid = 1500;
in
{
  sops.secrets."qbittorrent/api-key" = { };

  sops.templates."qBittorrent.conf" = {
    mode = "0444";
    content = ''
      [BitTorrent]
      Session\DefaultSavePath=${downloadDir}
      Session\TempPath=${downloadDir}/incomplete
      Session\TempPathEnabled=true
      Session\Port=${toString vpn.forwardedPort}
      Session\UseRandomPort=false
      Session\QueueingSystemEnabled=true
      Session\MaxActiveDownloads=5
      Session\MaxActiveUploads=-1
      Session\MaxActiveTorrents=-1
      Session\IgnoreSlowTorrentsForQueueing=true
      Session\SlowTorrentsDownloadRate=10

      [Preferences]
      WebUI\LocalHostAuth=false
      WebUI\AuthSubnetWhitelistEnabled=true
      WebUI\AuthSubnetWhitelist=10.100.0.0/24
      WebUI\APIKey=${config.sops.placeholder."qbittorrent/api-key"}
    '';
  };

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
      lidarr = {
        name = "Lidarr";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.lidarr.settings.server.port;
        full-domain = "lidarr.vanstraten.cloud";
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
      seerr = {
        name = "seerr";
        mode = "http";
        destination = containerIp;
        destination-port = cfg.services.seerr.port;
        full-domain = "seerr.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.servarr = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/run/secrets/qBittorrent.conf" = {
        hostPath = config.sops.templates."qBittorrent.conf".path;
        isReadOnly = true;
      };

      "/var/lib/qBittorrent" = {
        hostPath = "/tank/appdata/qbittorrent";
        isReadOnly = false;
      };
      "/var/lib/sonarr" = {
        hostPath = "/tank/appdata/sonarr";
        isReadOnly = false;
      };
      "/var/lib/radarr" = {
        hostPath = "/tank/appdata/radarr";
        isReadOnly = false;
      };
      "/var/lib/lidarr" = {
        hostPath = "/tank/appdata/lidarr";
        isReadOnly = false;
      };
      "/var/lib/prowlarr" = {
        hostPath = "/tank/appdata/prowlarr";
        isReadOnly = false;
      };
      "/var/lib/private/seerr" = {
        hostPath = "/tank/appdata/seerr";
        isReadOnly = false;
      };

      ${mediaDir} = {
        hostPath = "/tank/media";
        isReadOnly = false;
      };
    };

    config =
      { config, pkgs, ... }:
      let
        mkAuthEnv =
          app:
          pkgs.writeText "${app}-auth.env" ''
            ${lib.toUpper app}__AUTH__METHOD=External
            ${lib.toUpper app}__AUTH__REQUIRED=DisabledForLocalAddresses
          '';
      in
      {
        users.groups.media.gid = mediaGid;

        users.users = {
          qbittorrent.extraGroups = [ "media" ];
          sonarr.extraGroups = [ "media" ];
          radarr.extraGroups = [ "media" ];
          lidarr.extraGroups = [ "media" ];
        };

        systemd.tmpfiles.settings."10-servarr-media" =
          lib.genAttrs
            [
              mediaDir
              downloadDir
              "${downloadDir}/incomplete"
              "${mediaDir}/Shows"
              "${mediaDir}/Movies"
              "${mediaDir}/Music"
            ]
            (_: {
              d = {
                user = "root";
                group = "media";
                mode = "2775";
              };
            });

        services = {
          qbittorrent = {
            enable = true;
            openFirewall = true;
            group = "media";
            configFile = "/run/secrets/qBittorrent.conf";
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
          lidarr = {
            enable = true;
            openFirewall = true;
            environmentFiles = [ (mkAuthEnv "lidarr") ];
          };
          prowlarr = {
            enable = true;
            openFirewall = true;
            environmentFiles = [ (mkAuthEnv "prowlarr") ];
          };
          flaresolverr = {
            enable = true;
          };
          unpackerr = {
            enable = true;
            group = "media";
            settings = {
              sonarr = [
                {
                  api_key = "cfaf38ec54a84c62a9c1e88225866068";
                  url = "http://127.0.0.1:${builtins.toString config.services.sonarr.settings.server.port}";
                }
              ];
              radarr = [
                {
                  api_key = "cf304584f20e45c9a5f308f5580d236d";
                  url = "http://127.0.0.1:${builtins.toString config.services.radarr.settings.server.port}";
                }
              ];
            };
          };
          seerr = {
            enable = true;
            openFirewall = true;
          };
        };

        systemd.services = (
          lib.genAttrs [ "qbittorrent" "sonarr" "radarr" "lidarr" ] (_: {
            serviceConfig.UMask = lib.mkForce "0002";
          })
        );

        networking = {
          nameservers = [ vpn.dns ];

          hosts = {
            ${lib.head (lib.splitString "/" hostConfig.containers.jellyfin.localAddress)} = [
              "jellyfin.vanstraten.cloud"
            ];
          };

          firewall = {
            allowedTCPPorts = [ vpn.forwardedPort ];
            allowedUDPPorts = [ vpn.forwardedPort ];
          };
        };

        system.stateVersion = lib.mkForce "26.05";
      };
  };
}
