{ lib, config, ... }:
{
  programs.nushell.enable = true;

  programs.nushell.configFile.source = ./config.nu;
  programs.nushell.envFile.source = ./env.nu;
  programs.nushell.environmentVariables = builtins.mapAttrs (
    _: value: toString value
  ) config.home.sessionVariables;
  programs.nushell.shellAliases = builtins.mapAttrs (
    _: value: lib.mkForce (builtins.replaceStrings [ "$(" ] [ "(" ] value)
  ) config.home.shellAliases;
}
