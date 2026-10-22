{ self, ... }:
{ config, ... }:
{
  home.stateVersion = "25.11";
  home.sessionPath = [
    "$HOME/.cargo/bin/"
    "$HOME/.mozbuild/clang/bin/"
  ];

  imports = [
    self.homeModules.all
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = [ "firefox-enterprise.desktop" ];
        thunderbird = [ "thunderbird.desktop" ];
        signal = [ "signal.desktop" ];
      in
      {
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/xhtml+xml" = browser;
        "text/html" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/unknown" = browser;

        "application/x-extension-ics" = thunderbird;
        "message/rfc822" = thunderbird;
        "text/calendar" = thunderbird;
        "x-scheme-handler/mailto" = thunderbird;
        "x-scheme-handler/mid" = thunderbird;
        "x-scheme-handler/webcal" = thunderbird;
        "x-scheme-handler/webcals" = thunderbird;

        "x-scheme-handler/sgnl" = signal;
        "x-scheme-handler/signalcaptcha" = signal;
      };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "firefox-enterprise.desktop"
        "thunderbird.desktop"
        "signal.desktop"
      ];
    };
  };

  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "Michael van Straten";
        user.email = "mvanstraten@mozilla.com";
      };
      signing.key = "${config.home.homeDirectory}/.ssh/id_ecdsa.pub";
      signing.signByDefault = true;
    };
    lazygit.enable = true;
    nixvim.enable = true;
    tmux.enable = true;
    bash.enable = true;
    starship.enable = true;
    starship.enableBashIntegration = true;
    mach.enable = true;
    moz-phab.enable = true;
  };
}
