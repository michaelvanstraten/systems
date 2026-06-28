{ authentik-nix, ... }:
{ config, pkgs, ... }:
{
  sops.secrets."authentik/authentik-env" = {
    sopsFile = ./.env;
    format = "dotenv";
  };

  containers.authentik = {
    localAddress = "10.100.0.3/24";

    bindMounts = {
      "/run/secrets/authentik/authentik-env" = {
        hostPath = config.sops.secrets."authentik/authentik-env".path;
        isReadOnly = true;
      };

      "/srv/authentik" = {
        hostPath = "/srv/authentik";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "/srv/authentik/postgresql";
        isReadOnly = false;
      };
    };

    config =
      { pkgs, ... }:
      {
        imports = [
          authentik-nix.nixosModules.default
        ];

        networking = {
          hosts = {
            "10.100.0.2" = [ "sso.vanstraten.cloud" ];
          };
          firewall.allowedTCPPorts = [
            9000
          ];
        };

        services = {
          authentik = {
            enable = true;
            environmentFile = "/run/secrets/authentik/authentik-env";
            settings = {
              email = {
                host = "in-v3.mailjet.com";
                port = 25;
                use_tls = true;
                from = "authentik@vanstraten.cloud";
              };
              disable_startup_analytics = true;
              avatars = "initials";
              storage.media.file.path = "/srv/authentik";
            };
          };
        };
      };
  };

  networking.nat.forwardPorts = [
    {
      sourcePort = 389;
      destination = "10.100.0.3:3389";
      proto = "tcp";
    }
    {
      sourcePort = 636;
      destination = "10.100.0.3:6636";
      proto = "tcp";
    }
  ];

  networking.firewall = {
    allowedTCPPorts = [
      389
      636
    ];
  };
}
