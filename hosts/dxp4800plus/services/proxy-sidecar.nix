{ config, ... }:
let
  containerIp = "10.100.0.4";
  residentialPort = 1080;
in
{
  sops.secrets."residential-proxy/username" = { };
  sops.secrets."residential-proxy/password" = { };

  sops.templates."soax-auth".content = ''
    ${config.sops.placeholder."residential-proxy/username"} ${
      config.sops.placeholder."residential-proxy/password"
    }
  '';

  containers.proxy-sidecar = {
    localAddress = "${containerIp}/24";

    bindMounts."/run/secrets/soax-auth" = {
      hostPath = config.sops.templates."soax-auth".path;
      isReadOnly = true;
    };

    config =
      { pkgs, ... }:
      let
        gostConfig = (pkgs.formats.yaml { }).generate "gost.yaml" {
          services = [
            {
              name = "socks5-residential";
              addr = ":${toString residentialPort}";
              handler = {
                type = "socks5";
                chain = "chain-soax";
              };
              listener.type = "tcp";
            }
          ];
          chains = [
            {
              name = "chain-soax";
              hops = [
                {
                  name = "hop-0";
                  nodes = [
                    {
                      name = "soax";
                      addr = "proxy.soax.com:5000";
                      connector = {
                        type = "socks5";
                        auth.file = "/run/credentials/gost.service/soax-auth";
                      };
                      dialer.type = "tcp";
                    }
                  ];
                }
              ];
            }
          ];
        };
      in
      {
        networking.firewall.allowedTCPPorts = [ residentialPort ];

        systemd.services.gost = {
          description = "GOST SOCKS5 residential proxy";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.gost}/bin/gost -C ${gostConfig}";
            Restart = "on-failure";
            RestartSec = "5s";
            DynamicUser = true;
            LoadCredential = "soax-auth:/run/secrets/soax-auth";
          };
        };
      };
  };
}
