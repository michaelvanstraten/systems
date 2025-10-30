{ self, ... }:
{ config, pkgs, ... }:
{
  imports = [ self.homeModules.all ];

  home = {
    packages = [
      pkgs.alacritty
      pkgs.utm
      pkgs.grandperspective
    ];

    stateVersion = "24.05";
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    alacritty.enable = true;
    git = {
      enable = true;
    };
    karabiner-elements.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
  };

  targets.darwin = {
    defaults."com.apple.dock".persistent-apps = config.lib.darwin.mkPersistentApps [
      "/System/Applications/Mail.app/"
      "/Applications/Signal.app/"
      "/System/Applications/Messages.app/"
      "/Applications/WhatsApp.app/"
      "/System/Applications/Reminders.app/"
      "/System/Applications/Calendar.app/"
      "${pkgs.alacritty}/Applications/Alacritty.app/"
      "/Applications/Firefox Nightly.app"
      "/Applications/Bitwarden.app/"
      "/System/Applications/System Settings.app/"
    ];

    defaultbrowser = "nightly";
  };
}
