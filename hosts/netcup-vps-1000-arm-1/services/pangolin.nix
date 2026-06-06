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
          package =
            let
              react-is = pkgs.fetchzip {
                url = "https://registry.npmjs.org/react-is/-/react-is-19.2.6.tgz";
                hash = "sha256-oYXgCz6C1vdf2uujesEifDgH3J1KNAq1QY7wvIhT/xQ=";
              };
            in
            pkgs.fosrl-pangolin.overrideAttrs (
              final: prev: {
                version = "1.19.4";

                src = pkgs.fetchFromGitHub {
                  owner = "fosrl";
                  repo = "pangolin";
                  tag = final.version;
                  hash = "sha256-Joo7N92ZbKybD15ojIIoEtjLjzcho5PqAzuGlj17zag=";
                };

                npmDeps = pkgs.fetchNpmDeps {
                  inherit (final) src;
                  hash = "sha256-n3VMToqPUwDyDbFOceSjVl8/GPnu4HH3g2IlXsbl8rs=";
                };

                patches = [ "${private-patches}/pangolin.patch" ];

                postPatch = ''
                  substituteInPlace server/lib/consts.ts --replace-fail \
                    'export const APP_VERSION = "${lib.versions.majorMinor final.version + ".0"}";' \
                    'export const APP_VERSION = "${final.version}";'
                '';

                preBuild = ''
                  cp -r ${react-is} node_modules/react-is
                  chmod -R u+w node_modules/react-is
                ''
                + (prev.preBuild or "");

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
