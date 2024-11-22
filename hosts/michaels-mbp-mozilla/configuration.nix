{ self, ... } @ inputs:
{ pkgs, ... }:
{
  imports = with self.darwinModules; [
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
    computerName = "Michaels MacBook Pro at Mozilla";
    hostName = "michaels-mbp-mozilla";
  };

  users.users.michael = {
    createHome = true;
    description = "Michael van Straten";
    home = "/Users/michael/";
    name = "michael";
    shell = pkgs.fish;
  };

  system.stateVersion = 4;

  services.skhd.enable = true;
  services.yabai.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.michael = import ./home.nix inputs;

  environment.systemPackages = with pkgs; [
    darwin.trash
    git-cinnabar
  ];
}
