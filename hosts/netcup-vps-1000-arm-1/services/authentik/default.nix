{ authentik-nix, ... }:
{ config, pkgs, ... }:
{
  sops.secrets."authentik/authentik-env" = {
    sopsFile = ./.env;
    format = "dotenv";
  };

  # sops.secrets."authentik/ldap-env" = {
  #   sopsFile = ./ldap.env;
  #   format = "dotenv";
  # };

  containers.authentik = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.3/24";

    bindMounts = {
      "/run/secrets/authentik/authentik-env" = {
        hostPath = config.sops.secrets."authentik/authentik-env".path;
        isReadOnly = true;
      };

      # "/run/secrets/authentik/ldap-env" = {
      #   hostPath = config.sops.secrets."authentik/ldap-env".path;
      #   isReadOnly = true;
      # };
      #
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

        system.stateVersion = "26.05";

        networking = {
          useNetworkd = true;
          useHostResolvConf = false;
          nameservers = [
            "8.8.8.8"
            "1.1.1.1"
          ];
          hosts = {
            "10.100.0.2" = [ "sso.vanstraten.cloud" ];
          };
          firewall.allowedTCPPorts = [
            9000
            # 3389
            # 6636
          ];
        };

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.3/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
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
          #
          # authentik-ldap = {
          #   enable = true;
          #   environmentFile = "/run/secrets/authentik/ldap-env";
          # };
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
