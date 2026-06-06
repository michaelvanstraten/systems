{ private-patches, ... }:
{ config, pkgs, ... }:
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

    config =
      { config, lib, ... }:
      {
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
          firewall.enable = false;
        };

        environment.systemPackages = [
          config.services.pangolin.package
        ];

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.100.0.2/24";
            Gateway = "10.100.0.1";
            DHCP = "no";
            LinkLocalAddressing = "no";
          };
        };

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
              telemetry.anonymous_usage = false;
            };
            domains = {
              domain1 = {
                prefer_wildcard_cert = true;
              };
            };
            flags = {
              require_email_verification = false;
              disable_signup_without_invite = true;
              enable_integration_api = true;
            };
          };
          package = pkgs.fosrl-pangolin.overrideAttrs {
            patches = [ "${private-patches}/pangolin.patch" ];
          };
        };

        # Give pangolin CAP_DAC_READ_SEARCH so it can read acme.json for
        # acmeCertSync without changing the file's 600 permissions that
        # Traefik strictly requires.
        systemd.services.pangolin.serviceConfig.AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];

        services.traefik = {
          environmentFiles = [ "/run/secrets/traefik.env" ];
          dynamicConfigOptions.http = {
            routers = {
              authentik-router-redirect = {
                rule = "Host(`sso.${config.services.pangolin.baseDomain}`)";
                service = "authentik-service";
                entryPoints = [ "web" ];
                middlewares = [ "redirect-to-https" ];
              };
              authentik-router = {
                rule = "Host(`sso.${config.services.pangolin.baseDomain}`)";
                service = "authentik-service";
                entryPoints = [ "websecure" ];
                tls.certResolver = "letsencrypt";
              };
            };

            services = {
              authentik-service.loadBalancer.servers = [
                { url = "http://10.100.0.3:9000"; }
              ];
            };
          };
        };
      };
  };

  networking.nat.forwardPorts = [
    {
      sourcePort = 80;
      destination = "10.100.0.2:80";
      proto = "tcp";
    }
    {
      sourcePort = 443;
      destination = "10.100.0.2:443";
      proto = "tcp";
    }
    {
      sourcePort = 51820;
      destination = "10.100.0.2:51820";
      proto = "udp";
    }
    {
      sourcePort = 21820;
      destination = "10.100.0.2:21820";
      proto = "udp";
    }
  ];

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
