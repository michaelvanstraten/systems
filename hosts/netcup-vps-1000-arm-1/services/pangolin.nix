{ config, ... }:
{
  sops.secrets."pangolin/server_secret" = { };
  sops.secrets."cloudflare/dns_api_token" = { };

  sops.templates."pangolin.env" = {
    content = ''
      SERVER_SECRET=${config.sops.placeholder."pangolin/server_secret"}
    '';
  };
  sops.templates."traefik.env" = {
    content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/dns_api_token"}
    '';
  };

  containers.pangolin = {
    autoStart = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.2/24";
    privateNetwork = true;

    forwardPorts = [
      {
        hostPort = 80;
      }
      {
        hostPort = 443;
      }
      {
        hostPort = 51820;
        protocol = "udp";
      }
      {
        hostPort = 21820;
        protocol = "udp";
      }
    ];

    bindMounts = {
      "/run/secrets/pangolin.env" = {
        hostPath = config.sops.templates."pangolin.env".path;
        isReadOnly = true;
      };

      "/run/secrets/traefik.env" = {
        hostPath = config.sops.templates."traefik.env".path;
        isReadOnly = true;
      };

      "/var/lib/pangolin" = {
        isReadOnly = false;
        hostPath = "/var/lib/pangolin";
      };
    };

    config = {
      system.stateVersion = "26.05";

      networking.defaultGateway = "10.100.0.1";
      networking.firewall.enable = false;

      services.pangolin = {
        enable = true;
        dnsProvider = "cloudflare";
        baseDomain = "vanstraten.cloud";
        letsEncryptEmail = "michael@vanstraten.de";
        environmentFile = "/run/secrets/pangolin.env";
        openFirewall = true;
        settings = {
          app = {
            log_level = "info";
          };
          domains = {
            domain1 = {
              prefer_wildcard_cert = true;
            };
          };
          flags = {
            require_email_verification = false;
            disable_signup_without_invite = true;
          };
        };
      };

      services.traefik.environmentFiles = [ "/run/secrets/traefik.env" ];
    };

  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      51820
      21820
    ];
  };
}
