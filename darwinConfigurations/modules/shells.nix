{ config, lib, ... }:
{
  environment.shells = lib.mapAttrsToList (_: user: user.shell) config.users.users;

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.zsh.enable = true;
}
