{ self, ... }:
let
  inherit (self) homeModules;
in
{ pkgs, lib, ... }:
{
  imports = with homeModules; [
    Alacritty
    Firefox
    Karabiner-Elements.default
    Lazygit
    Poetry
    VSCodium
    darwin.defaults
    git
    nvim.default
    sesh
    shells
    starship
    tmux.default
  ];

  xdg.enable = true;
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      wget
      nil
      stylua
      lua-language-server
      nixfmt-rfc-style
      firefox-bin
      ltex-ls
      podman
      podman-compose
      nodejs_22
      tree-sitter
    ];
  };

  programs = {
    sesh.enable = true;

    thefuck.enable = true;

    zoxide.enable = true;
    zoxide.options = [ "--cmd cd" ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      userName = "Michael van Straten";
      userEmail = "michael@vanstraten.de";
    };

    bat.enable = true;

    jq.enable = true;
  };

  targets.darwin.defaults."com.apple.dock".persistent-apps =
    (homeModules.darwin.utils { inherit lib; }).mkPersistentApps
      [
        # Add wanted items back to the dock
        "/System/Applications/Mail.app/"
        "/Applications/Bitwarden.app/"
        "/System/Applications/Messages.app/"
        "/Applications/WhatsApp.app/"
        "/System/Applications/Calendar.app/"
        "/System/Applications/Reminders.app/"
        "/Applications/Alacritty.app/"
        "/Applications/Firefox Nightly.app/"
        "/System/Applications/System Settings.app/"
      ];
}
