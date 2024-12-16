{
  pkgs,
  config,
  lib,
  ...
}:
{
  environment = {
    shellAliases = {
      c = "clear";
      l = "ls";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
      ls = "eza";
      tree = "eza --tree";
    };

    shells = lib.mapAttrsToList (_: user: user.shell) config.users.users;

    systemPackages = [
      pkgs.eza
    ];
  };
}
