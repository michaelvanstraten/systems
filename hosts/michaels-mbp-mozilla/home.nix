{ self, ... }:
{ config, pkgs, ... }:
{
  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "mvanstraten@mozilla.com";
  };

  nixpkgs.config.allowBroken = true;

  nixpkgs.overlays = [
    (self: super: {
      python312 = super.python312.override {
        packageOverrides = python-self: python-super: {
          glean-sdk = python-super.glean-sdk.overridePythonAttrs (old: {
            # Disable pytest and other checks
            doCheck = false;
          });
        };
      };
    })
  ];

  home.packages = [
    pkgs.alacritty
    pkgs.element-desktop
    pkgs.podman
    pkgs.podman-compose

    pkgs.git-cinnabar
    pkgs.mozphab
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
    self.homeModules.git
    self.homeModules.karabiner-elements
    self.homeModules.lazygit
    self.homeModules.mach-command
    self.homeModules.mozconfig
    self.homeModules.nvim
    self.homeModules.shell-environment
    self.homeModules.tmux
    self.homeModules.vscodium
  ];
}
