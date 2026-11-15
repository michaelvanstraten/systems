{ config, ... }:
let
  containerIp = "10.100.0.8";
  nextcloudPort = 80;
  fqdn = "nextcloud.vanstraten.cloud";
in
{
  sops.secrets."nextcloud/config" = {
    sopsFile = ./secrets.json;
    format = "binary";
  };

  services.newt.blueprint = {
    public-resources = {
      nextcloud = {
        name = "Nextcloud";
        protocol = "http";
        ssl = true;
        full-domain = fqdn;
        targets = [
          {
            method = "http";
            hostname = containerIp;
            port = nextcloudPort;
          }
        ];
      };
    };
  };

  containers.nextcloud = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/run/secrets/nextcloud-config" = {
        hostPath = config.sops.secrets."nextcloud/config".path;
        isReadOnly = true;
      };

      "/var/lib/nextcloud" = {
        hostPath = "/tank/appdata/nextcloud";
        isReadOnly = false;
      };
      "/var/lib/postgresql" = {
        hostPath = "/tank/appdata/nextcloud-db";
        isReadOnly = false;
      };
    };

    config =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        networking.firewall.allowedTCPPorts = [ nextcloudPort ];

        environment.systemPackages = [
          pkgs.convmv
          pkgs.trash-cli
        ];

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud35;
          hostName = fqdn;
          config = {
            dbtype = "pgsql";
          };
          secretFile = "/run/secrets/nextcloud-config";
          database.createLocally = true;
          configureRedis = true;
          https = true;
          notify_push = {
            enable = true;
            bendDomainToLocalhost = true;
            # TLS is terminated at Pangolin; nginx in here only speaks plain
            # HTTP, so the daemon and the setup self-test have to use http.
            nextcloudUrl = "http://${fqdn}";
          };
          settings = {
            overwriteprotocol = "https";
            maintenance_window_start = 1;
            default_phone_region = "DE";
            serverid = 0;
            trusted_proxies = [
              "10.100.0.0/24"
            ];
          };
          phpOptions = {
            "opcache.interned_strings_buffer" = "16";
          };
          extraApps = {
            inherit (config.services.nextcloud.package.packages.apps)
              spreed
              contacts
              calendar
              ;
            oidc_login = pkgs.fetchNextcloudApp {
              sha256 = "sha256-2E42FuhlJZwUKvbPQLbwCSIorXi+2EP4XGV19FlCiEs=";
              url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.4.0/oidc_login.tar.gz";
              license = "gpl3";
            };
          };
          extraAppsEnable = true;
          phpExtraExtensions = all: [ all.smbclient ];
        };

        # notify_push:setup stores the URL it tested (http) as the endpoint
        # advertised to clients; replace it with the public https one.
        systemd.services.nextcloud-notify_push_setup.serviceConfig.ExecStartPost =
          "${lib.getExe config.services.nextcloud.occ} config:app:set notify_push base_endpoint --value=https://${fqdn}/push";

        services.postgresql = {
          package = pkgs.postgresql_16;
          # oc_filecache makes up nearly the whole database (~1.8 GB); the
          # 128MB default cannot hold it.
          settings.shared_buffers = "2GB";
        };
      };
  };
}
