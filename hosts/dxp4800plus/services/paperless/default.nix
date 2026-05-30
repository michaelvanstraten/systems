{ config, ... }:
let
  containerIp = "10.100.0.6";
  paperlessPort = 28981;
  fqdn = "paperless.vanstraten.cloud";
in
{
  sops.secrets."paperless/paperless-env" = {
    sopsFile = ./.env;
    format = "dotenv";
  };

  services.newt.blueprint = {
    public-resources = {
      paperless-ngx = {
        name = "Paperless-ngx";
        protocol = "http";
        ssl = true;
        full-domain = fqdn;
        targets = [
          {
            method = "http";
            hostname = containerIp;
            port = paperlessPort;
          }
        ];
      };
    };
  };

  containers.paperless = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "${containerIp}/24";

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
            Address = "${containerIp}/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

        networking.firewall.allowedTCPPorts = [ paperlessPort ];

        services.paperless = {
          enable = true;
          environmentFile = "/run/secrets/paperless-env";
          address = "0.0.0.0";
          port = paperlessPort;
          settings = {
            PAPERLESS_URL = "https://${fqdn}";
            PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          };
        };
      };
  };
}
