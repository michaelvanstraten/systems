{ self, ... }:
{ pkgs, ... }:
{
  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "michael@vanstraten.de";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.alacritty
    pkgs.firefox-bin
    pkgs.keepassxc
    pkgs.podman
    pkgs.podman-compose
    pkgs.signal-desktop
    pkgs.utm
  ];

  targets.darwin.defaults."com.apple.dock".persistent-apps = self.lib.darwin.mkPersistentApps [
    "/System/Applications/Mail.app/"
    "${pkgs.signal-desktop}/Applications/Signal.app/"
    "/System/Applications/Messages.app/"
    "/Applications/WhatsApp.app/"
    "/System/Applications/Reminders.app/"
    "/System/Applications/Calendar.app/"
    "${pkgs.alacritty}/Applications/Alacritty.app/"
    "${pkgs.firefox-bin}/Applications/Firefox.app/"
    "/Applications/Bitwarden.app/"
    "/System/Applications/System Settings.app/"
  ];

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
    self.homeModules.nvim
    self.homeModules.sesh
    self.homeModules.shell-environment
    self.homeModules.tmux
  ];
}
