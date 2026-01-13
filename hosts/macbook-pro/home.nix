{ self, ... }:
{ config, pkgs, ... }:
{
  imports = [ self.homeModules.all ];

  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  programs = {
    alacritty.enable = true;
    alacritty.package = null;
    git.enable = true;
    karabiner-elements.enable = false;
    lazygit.enable = true;
    mach.enable = true;
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
      "/Applications/Alacritty.app/"
      "/Applications/Nix Apps/Firefox.app/"
      "/Applications/Nix Apps/Bitwarden.app/"
      "/System/Applications/System Settings.app/"
    ];

    defaultbrowser = "firefox";
  };
}
