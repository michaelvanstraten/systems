{ BetterFox, ... }:
{ lib, pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    # Let Firefox package be managed by the system
    package = lib.mkDefault pkgs.firefox-bin;

    policies = {
      DisableAppUpdate = true;
    };

    profiles.michael = {
      settings = {
        # PREF: enable SameSite Cookies
        "network.cookie.sameSite.laxByDefault" = true;
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "network.cookie.sameSite.schemeful" = true;
        # PREF: clear browsing data on shutdown, while respecting site exceptions
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown.history" = true;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.sessions" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = false;
        "browser.sessionstore.privacy_level" = 2;
        # PREF: CRTL scroll to zoom
        "mousewheel.with_meta.action" = 3;
        # PREF: Disable translations
        "browser.translations.enable" = false;
      };

      extraConfig = builtins.readFile "${BetterFox}/user.js";
    };
  };
}
