{ self, ... }:
let
  inherit (self) homeModules;
in
{ pkgs, ... }:
{
  imports = with homeModules; [
    Alacritty
    darwin.defaults
    darwin.defaultbrowser
    darwin.applications
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
      nixd
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
    zoxide.options = [ "--cmd j" ];
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

  targets.darwin.defaults."com.apple.dock".persistent-apps = self.lib.darwin.mkPersistentApps [
    "/System/Applications/Mail.app/"
    "${pkgs.element-desktop}/Applications/Element.app"
    "/Applications/Slack.app" # Externally managed
    "/System/Applications/Reminders.app/"
    "/System/Applications/Calendar.app/"
    "${pkgs.alacritty}/Applications/Alacritty.app"
    "/Applications/Firefox Nightly.app" # Externally managed
    "/System/Applications/System Settings.app/"
  ];
}
