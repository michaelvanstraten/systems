{ config, ... }:
{
  sops.secrets."nextcloud/adminpass" = { };
  sops.secrets."nextcloud/config" = {
    sopsFile = ./secrets.json;
    format = "binary";
  };

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.8/24";

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

          firewall.allowedTCPPorts = [ 80 ];
        };

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.8/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = "nextcloud.vanstraten.cloud";
          config = {
            adminpassFile = "/run/secrets/nextcloud-admin-pass";
            dbtype = "pgsql";
          };
          secretFile = "/run/secrets/nextcloud-config";
          database.createLocally = true;
          configureRedis = true;
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
        };

        services.postgresql.package = pkgs.postgresql_16;
      };
  };
}
