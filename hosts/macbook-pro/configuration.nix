{ self, ... }:
{ pkgs, ... }:
{
  system.stateVersion = 4;
  system.primaryUser = "michaelvanstraten";

  users.users.michaelvanstraten = {
    description = "Michael van Straten";
    home = "/Users/michaelvanstraten";
    name = "michaelvanstraten";
    shell = pkgs.fish;
    uid = 501;
  };

  networking = {
    computerName = "Michael’s MacBook Pro";
    hostName = "macbook-pro";
  };

  nix.linux-builder.enable = true;
  nix.linux-builder.ephemeral = true;

  imports = [
    self.darwinModules."applications/karabiner-elements"
    self.darwinModules."applications/yabai"
    self.darwinModules.applications
    self.darwinModules.common
    self.sharedModules.nix
    self.sharedModules.nix-remote-builders
  ];
}
