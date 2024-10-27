{ self, ... }:
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

  users.users.mozilla = {
    createHome = true;
    description = "Michael van Straten";
    home = "/Users/mozilla/";
    name = "mozilla";
    shell = pkgs.fish;
  };

  system.stateVersion = 4;

  services.skhd.enable = true;
  services.yabai.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.mozilla = import ../../homeConfigurations/mozilla.nix;

  environment.systemPackages = with pkgs; [ darwin.trash ];
}