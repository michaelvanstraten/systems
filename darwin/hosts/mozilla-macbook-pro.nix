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

  users.users.mozilla = {
    createHome = true;
    description = "Michael van Straten";
    home = "/Users/mozilla/";
    name = "mozilla";
    shell = pkgs.fish;
  };

  system.stateVersion = 4;

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.mozilla = import ../../dotfiles/mozilla;

  environment.systemPackages = with pkgs; [ darwin.trash ];
}
