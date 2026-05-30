{
  nix-homebrew,
  homebrew-core,
  homebrew-cask,
  primaryUser,
  ...
}:
{ config, ... }:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;

    enableRosetta = true;

    user = primaryUser;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };

    mutableTaps = false;
  };

  homebrew.enable = true;

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;

  homebrew.casks = [
    "alacritty"
    "anki"
    "bambu-studio"
    "freecad"
    "macfuse"
    "nextcloud"
    "rustdesk"
    "signal"
    "steam"
    "veracrypt"
    "whatsapp"
    "bitwarden"
  ];

  homebrew.onActivation.cleanup = "uninstall";
}
