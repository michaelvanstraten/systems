{ self, moz-phab, ... }:
{ config, pkgs, ... }:
{
  imports = [
    self.homeModules.all
  ];

  home = {
    stateVersion = "25.11";
  };

  programs = {
    alacritty.enable = true;
    alacritty.package = null;
    git = {
      enable = true;
      settings = {
        user.name = "Michael van Straten";
        user.email = "mvanstraten@mozilla.com";
      };
      signing.key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signing.signByDefault = true;
    };
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    bash.enable = true;
    starship.enable = true;
  };

  targets.darwin = {
    defaults."com.apple.dock".persistent-apps = config.lib.darwin.mkPersistentApps [
      "/Applications/Nix Apps/Alacritty.app"
      "/Applications/Nix Apps/Firefox.app"
      "/System/Applications/System Settings.app/"
    ];

    defaultbrowser = "firefox";
  };
}
