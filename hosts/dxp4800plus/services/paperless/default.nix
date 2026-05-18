{ config, ... }:
{
  sops.secrets."paperless/paperless-env" = {
    sopsFile = ./.env;
    format = "dotenv";
  };

  containers.paperless = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.6/24";

    bindMounts = {
      "/run/secrets/paperless-env" = {
        hostPath = config.sops.secrets."paperless/paperless-env".path;
        isReadOnly = true;
      };

      "/var/lib/paperless" = {
        hostPath = "/tank/appdata/paperless";
        isReadOnly = false;
      };
    };

    config =
      { pkgs, ... }:
      {
        system.stateVersion = "26.05";

        networking.useNetworkd = true;
        networking.useHostResolvConf = false;
        networking.nameservers = [
          "8.8.8.8"
          "1.1.1.1"
        ];

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.6/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        networking.firewall.allowedTCPPorts = [ 28981 ];

        services.paperless = {
          enable = true;
          environmentFile = "/run/secrets/paperless-env";
          address = "0.0.0.0";
          settings = {
            PAPERLESS_URL = "https://paperless.vanstraten.cloud";
            PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          };
        };
      };
  };
}
