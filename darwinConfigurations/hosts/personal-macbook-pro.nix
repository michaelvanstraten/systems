{ pkgs, ... }:
{
  imports = [
    ../modules/nix.nix
    ../modules/shells.nix
    ../modules/home-manager.nix
    ../modules/packages.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
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

  home-manager.users.michaelvanstraten = import ../../homeConfigurations/personal.nix;

  environment.systemPackages = with pkgs; [ darwin.trash ];
}
