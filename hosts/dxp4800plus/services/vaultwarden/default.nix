{ config, ... }:
let
  containerIp = "10.100.0.12";
  cfg = config.containers.vaultwarden.config;
  fqdn = "vaultwarden.vanstraten.cloud";
in
{
  sops.secrets."vaultwarden/vaultwarden-env" = {
    sopsFile = ./.env;
    format = "dotenv";
  };

  services.newt.blueprint = {
    public-resources = {
      vaultwarden = {
        name = "Vaultwarden";
        protocol = "http";
        ssl = true;
        full-domain = fqdn;
        targets = [
          {
            method = "http";
            hostname = containerIp;
            port = cfg.services.vaultwarden.config.ROCKET_PORT;
          }
        ];
      };
    };
  };

  containers.vaultwarden = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/var/lib/vaultwarden" = {
        hostPath = "/tank/appdata/vaultwarden";
        isReadOnly = false;
      };

      "/run/secrets/vaultwarden/vaultwarden-env" = {
        hostPath = config.sops.secrets."vaultwarden/vaultwarden-env".path;
        isReadOnly = true;
      };
    };

    config = {
      networking.firewall.allowedTCPPorts = [ cfg.services.vaultwarden.config.ROCKET_PORT ];

      services.vaultwarden = {
        enable = true;
        environmentFile = "/run/secrets/vaultwarden/vaultwarden-env";
        config = {
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8222;
          # Controls if new users can register
          SIGNUPS_ALLOWED = false;
          # Icon service
          ICON_SERVICE = "bitwarden";
        };
      };
    };
  };
}
