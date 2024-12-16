{ self, ... }:
{ pkgs, ... }:
{
  imports = with self.darwinModules; [
    applications
    environment
    home-manager
    karabiner-elements
    nix
    packages
    shells
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };

  networking = {
    computerName = "Michaels MacBook Pro";
    hostName = "michaels-mbp";
  };

  users.users.michaelvanstraten = {
    createHome = true;
    description = "Michael van Straten";
    home = "/Users/michaelvanstraten/";
    name = "michaelvanstraten";
    shell = pkgs.fish;
  };

  system.stateVersion = 4;

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.michaelvanstraten = self.lib.mkModule ./home.nix { };
}
