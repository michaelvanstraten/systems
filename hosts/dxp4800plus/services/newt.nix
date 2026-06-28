{ fosrl-newt, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."newt/id" = { };
  sops.secrets."newt/secret" = { };

  sops.templates."newt.env" = {
    content = ''
      NEWT_ID=${config.sops.placeholder."newt/id"}
      NEWT_SECRET=${config.sops.placeholder."newt/secret"}
    '';
  };

  containers.newt = {
    localAddress = "10.100.0.2/24";

    bindMounts = {
      "/run/secrets/newt.env" = {
        hostPath = config.sops.templates."newt.env".path;
        isReadOnly = true;
      };
    };

    config = {
      services.newt = {
        enable = true;
        package = fosrl-newt.packages.${pkgs.stdenv.system}.pangolin-newt;
        settings = {
          endpoint = "https://pangolin.vanstraten.cloud";
        };
        environmentFile = "/run/secrets/newt.env";
        blueprint = config.services.newt.blueprint;
      };
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
