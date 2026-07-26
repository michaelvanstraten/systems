{ fosrl-newt, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."newt/env" = { };

  services.newt = {
    enable = true;
    package = fosrl-newt.packages.${pkgs.stdenv.system}.pangolin-newt;
    environmentFile = config.sops.secrets."newt/env".path;
  };
}
