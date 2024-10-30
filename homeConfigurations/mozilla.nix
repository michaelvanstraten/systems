{ self, ... }:
let
  inherit (self) homeModules;
in
{ pkgs, lib, ... }:
{
  imports = with homeModules; [
    Alacritty
    darwin.defaults
    darwin.defaultbrowser
    Karabiner-Elements.default
    Poetry
    VSCodium
    Firefox
    git
    nvim.default
    Lazygit
    starship
    sesh
    shells
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
    firefox.enable = true;

    home-manager.enable = true;

    git = {
      userName = "Michael van Straten";
      userEmail = "mvanstraten@mozilla.com";
    };

    bat.enable = true;

    jq.enable = true;
  };

  targets.darwin.defaultbrowser = "nightly";

  targets.darwin.defaults."com.apple.dock".persistent-apps =
    (homeModules.darwin.utils { inherit lib; }).mkPersistentApps
      [
        # Add wanted items back to the dock
        "/System/Applications/Mail.app/"
        "/System/Applications/Calendar.app/"
        "/System/Applications/Reminders.app/"
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "${pkgs.firefox-nightly-bin}/Applications/Firefox Nightly.app"
        "${pkgs.slack}/Applications/Slack.app"
        "/System/Applications/System Settings.app/"
      ];
}
