{ private-patches, ... }:
{ config, pkgs, ... }:
let
  loopbackIPs = [ "89.58.36.215" ];
in
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
    localAddress = "10.100.0.2/24";

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
        networking = {
          hosts = {
            "10.100.0.2" = [ "sso.vanstraten.cloud" ];
          };
          firewall.enable = false;
        };

        environment.systemPackages = [
          config.services.pangolin.package
        ];

        services.pangolin = {
          enable = true;
          dnsProvider = "cloudflare";
          baseDomain = "vanstraten.cloud";
          letsEncryptEmail = "michael@vanstraten.de";
          environmentFile = "/run/secrets/pangolin.env";
          openFirewall = true;
          settings = {
            app = {
              log_level = "debug";
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
          package = pkgs.fosrl-pangolin.overrideAttrs (
            final: prev: {
              patches = [ "${private-patches}/pangolin.patch" ];

              env = (prev.env or { }) // {
                NODE_OPTIONS = "--max-old-space-size=6144";
              };

              postInstall = (prev.postInstall or "") + ''
                rm -rf $out/share/pangolin/.next/cache
                ln -s /var/cache/pangolin $out/share/pangolin/.next/cache
              '';
            }
          );
        };

        systemd.services.pangolin.serviceConfig = {
          AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
          ExecStartPre = [
            "+${pkgs.coreutils}/bin/rm -rf /var/lib/pangolin/.next"
          ];
          CacheDirectory = "pangolin";
        };

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
      inherit loopbackIPs;
    }
    {
      sourcePort = 443;
      destination = "10.100.0.2:443";
      proto = "tcp";
      inherit loopbackIPs;
    }
    {
      sourcePort = 51820;
      destination = "10.100.0.2:51820";
      proto = "udp";
      inherit loopbackIPs;
    }
    {
      sourcePort = 21820;
      destination = "10.100.0.2:21820";
      proto = "udp";
      inherit loopbackIPs;
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
