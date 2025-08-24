{ lib, config, ... }:
{
  programs.nushell = {
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
    environmentVariables = builtins.mapAttrs (_: value: toString value) config.home.sessionVariables;
    shellAliases = builtins.mapAttrs (
      _: value: lib.mkForce (builtins.replaceStrings [ "$(" ] [ "(" ] value)
    ) config.home.shellAliases;
  };
}
