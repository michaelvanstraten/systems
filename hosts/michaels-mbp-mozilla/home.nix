{ self, moz-phab, ... }:
{ config, pkgs, ... }:
{
  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "mvanstraten@mozilla.com";
  };

  nixpkgs.config.allowBroken = true;

  home.packages = [
    pkgs.alacritty
    pkgs.element-desktop
    pkgs.podman
    pkgs.podman-compose

    pkgs.git-cinnabar
    (pkgs.mozphab.overrideAttrs {
      src = moz-phab;
    })
  ];

  programs.firefox.package = null;

  targets.darwin.defaults."com.apple.dock".persistent-apps = config.lib.darwin.mkPersistentApps [
    "/System/Applications/Mail.app/"
    "${pkgs.element-desktop}/Applications/Element.app"
    "/Applications/Slack.app" # Externally managed
    "/System/Applications/Reminders.app/"
    "/System/Applications/Calendar.app/"
    "${pkgs.alacritty}/Applications/Alacritty.app"
    "/Applications/Firefox Nightly.app" # Externally managed
    "/System/Applications/System Settings.app/"
  ];

  targets.darwin.defaultbrowser = "nightly";

  imports = [
    self.homeModules."darwin/applications"
    self.homeModules."darwin/defaultbrowser"
    self.homeModules."darwin/defaults"
    self.homeModules.alacritty
    self.homeModules.firefox
    self.homeModules.karabiner-elements
    self.homeModules.lazygit
    self.homeModules.vscodium
    self.homeModules.git
    self.homeModules.mach-command
    self.homeModules.mozconfig
    self.homeModules.nvim
    self.homeModules.sesh
    self.homeModules.shell-environment
    self.homeModules.tmux
  ];
}
