{ pkgs, ... }:
{
  imports = [
    ../modules/nix.nix
    ../modules/skhd.nix
    ../modules/system.nix
    ../modules/yabai.nix
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

  home-manager.users.michaelvanstraten = import ../../dotfiles/michael;

  environment.systemPackages = with pkgs; [ darwin.trash ];
}
