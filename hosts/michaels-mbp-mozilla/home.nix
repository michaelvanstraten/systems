{ self, ... }:
{ pkgs, ... }:
{
  imports =
    with self.homeModules;
    [
      Alacritty
      Firefox
      Karabiner-Elements
      Lazygit
      Poetry
      VSCodium
      git
      nvim
      sesh
      shells
      starship
      tmux
    ]
    ++ [
      self.homeModules."darwin/defaults"
      self.homeModules."darwin/applications"
      self.homeModules."darwin/defaultbrowser"
    ];

  xdg.enable = true;
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      wget
      podman
      podman-compose
      nodejs_22
    ];
  };

  programs = {
    sesh.enable = true;

    thefuck.enable = true;

    zoxide.enable = true;
    zoxide.options = [ "--cmd j" ];
  };

  programs = {
    firefox.package = null;

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
