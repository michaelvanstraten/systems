{ self, ... }:
{ pkgs, ... }:
{
  system.stateVersion = 4;

  users.users.michaelvanstraten = {
    description = "Michael van Straten";
    home = "/Users/michaelvanstraten";
    name = "michaelvanstraten";
    shell = pkgs.nushell;
    uid = 501;
  };

  networking = {
    computerName = "Michaels MacBook Pro";
    hostName = "michaels-mbp";
  };

  environment.systemPackages = [
  ];

  imports = [
    self.darwinModules."applications/karabiner-elements"
    self.darwinModules.applications
    self.darwinModules.common
    self.sharedModules.nix
    self.sharedModules.nix-remote-builders
  ];
}
