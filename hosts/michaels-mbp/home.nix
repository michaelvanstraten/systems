{ self, ... }:
{ config, pkgs, ... }:
{
  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "michael@vanstraten.de";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.alacritty
    pkgs.utm
    pkgs.grandperspective
  ];

  targets.darwin.defaults."com.apple.dock".persistent-apps = config.lib.darwin.mkPersistentApps [
    "/System/Applications/Mail.app/"
    "/Applications/Signal.app/"
    "/System/Applications/Messages.app/"
    "/Applications/WhatsApp.app/"
    "/System/Applications/Reminders.app/"
    "/System/Applications/Calendar.app/"
    "${pkgs.alacritty}/Applications/Alacritty.app/"
    "/Applications/Firefox.app/"
    "/Applications/Bitwarden.app/"
    "/System/Applications/System Settings.app/"
  ];

  imports = [
    self.homeModules."darwin/applications"
    self.homeModules."darwin/defaultbrowser"
    self.homeModules."darwin/defaults"
    self.homeModules.alacritty
    self.homeModules.firefox
    self.homeModules.git
    self.homeModules.go
    self.homeModules.karabiner-elements
    self.homeModules.lazygit
    self.homeModules.nvim
    self.homeModules.shell-environment
    self.homeModules.tmux
    self.homeModules.vscodium
  ];
}
