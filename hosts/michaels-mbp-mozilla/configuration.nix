{ self, ... }@inputs:
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
    yabai
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };

  networking = {
    computerName = "Michaels MacBook Pro at Mozilla";
    hostName = "michaels-mbp-mozilla";
  };

  users.knownUsers = [ "michael" ];

  users.users.michael = {
    createHome = true;
    description = "Michael van Straten";
    home = "/Users/michael";
    name = "michael";
    shell = pkgs.fish;
    uid = 501;
  };

  system.stateVersion = 4;

  services.skhd.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.michael = import ./home.nix inputs;

  environment.systemPackages = with pkgs; [
    darwin.trash
    git-cinnabar
    clang
    clang-tools
    ripgrep
  ];
}
