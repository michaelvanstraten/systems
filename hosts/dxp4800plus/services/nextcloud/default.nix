{ config, ... }:
let
  containerIp = "10.100.0.8";
  nextcloudPort = 80;
  fqdn = "nextcloud.vanstraten.cloud";
in
{
  sops.secrets."nextcloud/adminpass" = { };
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
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/run/secrets/nextcloud-admin-pass" = {
        hostPath = config.sops.secrets."nextcloud/adminpass".path;
        isReadOnly = true;
      };

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
      { config, pkgs, ... }:
      {
        system.stateVersion = "26.05";

        networking = {
          useNetworkd = true;
          useHostResolvConf = false;
          nameservers = [
            "8.8.8.8"
            "1.1.1.1"
          ];

          firewall.allowedTCPPorts = [ nextcloudPort ];
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

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = fqdn;
          config = {
            adminpassFile = "/run/secrets/nextcloud-admin-pass";
            dbtype = "pgsql";
          };
          secretFile = "/run/secrets/nextcloud-config";
          database.createLocally = true;
          configureRedis = true;
          https = true;
          # notify_push.enable = true;
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
              sha256 = "sha256-KBa8A7aC0uS6FQoOSa7nIkaaYe+A2KeAtzfqoKw0Gn4=";
              url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.3.1/oidc_login.tar.gz";
              license = "gpl3";
            };
          };
          extraAppsEnable = true;
          phpExtraExtensions = all: [ all.smbclient ];
        };

        services.nginx.virtualHosts.${fqdn}.extraConfig = ''
          add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
        '';

        services.postgresql.package = pkgs.postgresql_16;
      };
  };
}
