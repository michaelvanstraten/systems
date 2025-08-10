{ self, moz-phab, ... }:
{ config, pkgs, ... }:
{
  imports = [
    self.homeModules.all
  ];

  home = {
    packages = [
      pkgs.alacritty
      pkgs.element-desktop
    ];

    stateVersion = "24.05";
  };

  nixpkgs = {
    config.allowBroken = true;

    overlays = [
      (self: super: {
        python3 = super.python3.override {
          packageOverrides = python-self: python-super: {
            glean-sdk = python-super.glean-sdk.overridePythonAttrs (old: {
              # Disable pytest and other checks
              doCheck = false;
            });
          };
        };
      })
    ];
  };

  programs = {
    alacritty.enable = true;
    firefox = {
      enable = true;
      package = null;
    };
    git = {
      enable = true;
      userName = "Michael van Straten";
      userEmail = "mvanstraten@mozilla.com";
    };
    lazygit.enable = true;
    karabiner-elements.enable = true;
    mach.enable = true;
    moz-phab = {
      enable = true;
      package = pkgs.mozphab.overridePythonAttrs (old: {
        src = moz-phab;
        doCheck = false;
      });
    };
    neovim.enable = true;
    tmux.enable = true;
  };

  targets.darwin = {
    defaults."com.apple.dock".persistent-apps = config.lib.darwin.mkPersistentApps [
      "/System/Applications/Mail.app/"
      "${pkgs.element-desktop}/Applications/Element.app"
      "/Applications/Slack.app" # Externally managed
      "/System/Applications/Reminders.app/"
      "/System/Applications/Calendar.app/"
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "/Applications/Firefox Nightly.app" # Externally managed
      "/System/Applications/System Settings.app/"
    ];

    defaultbrowser = "nightly";
  };
}
