{ self, ... }@inputs:
let
  inherit (self) darwinModules;
in
{ pkgs, ... }:
{
  imports = with darwinModules; [
    environment
    home-manager
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

  home-manager.users.michaelvanstraten = import ./home.nix inputs;

  environment.systemPackages = with pkgs; [ darwin.trash ];
}
