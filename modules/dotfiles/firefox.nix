{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixosArtwork = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixos-artwork";
    rev = "9d2cdedd73d64a068214482902adea3d02783ba8";
    hash = "sha256-//4BiRF1W5W2rEbw6MupiyDOjvcveqGtYjJ1mZfck9U=";
  };
in
{
  programs.firefox = {
    policies = {
      # Do not prompt for app updates if nix is managing Firefox
      DisableAppUpdate = !(isNull config.programs.firefox.package);
    };

    profiles.michael = {
      id = 0;

      settings = {
        # I often use new tabs as a clipboard extension
        "browser.search.suggest.enabled" = false;
        # CRTL scroll to zoom
        "mousewheel.with_meta.action" = 3;
        # PREF: do not autoplay media audio
        "media.autoplay.default" = 1;
        # PREF: set newt ab page to blank tab
        "browser.newtabpage.enabled" = false;
        # This is managed by home-manager
        "services.sync.engine.prefs" = false;
        # This is managed by Bitwarden
        "services.sync.engine.addresses" = false;
        "services.sync.engine.creditcards" = false;
        "services.sync.engine.passwords" = false;

        "browser.startup.homepage" = "https://www.tagesschau.de/";
      };

      search = {
        default = "ddg";
        engines = lib.mkMerge (
          [
            {
              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixosArtwork}/logo/nix-snowflake-colours.svg";
                definedAliases = [ "@np" ];
              };
              nixos-options = {
                name = "NixOS Options";
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${nixosArtwork}/logo/nix-snowflake-rainbow.svg";
                definedAliases = [ "@no" ];
              };
            }

          ]
          ++ (map
            (engineId: {
              ${engineId}.metaData.hidden = true;
            })
            [
              "bing"
              "ebay-de"
              "ecosia"
              "leo_ende_de"
              "wikipedia-de"
            ]
          )
        );
        order = [
          "ddg"
          "nix-packages"
          "nixos-options"
          "google"
        ];
        force = true;
      };
    };
  };

  lib.firefox-temp-profile = pkgs.writeShellApplication {
    name = "firefox-temp-profile";
    runtimeInputs = with pkgs; [
      nix
      rsync
      coreutils
    ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      cleanup() {
        if [[ -n "''${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
          # Just in case any files became read-only
          chmod -R u+w "$TEMP_DIR" >/dev/null 2>&1 || true
          rm -rf "$TEMP_DIR" || true
        fi
      }
      trap cleanup EXIT INT TERM

      TEMP_DIR="$(mktemp -d)"
      echo "Created temporary profile directory at: $TEMP_DIR"

      echo "Populating temporary profile with managed files..."
      rsync --recursive --copy-links --delete "${config.home.activationPackage}/home-files/Library/Application Support/Firefox/Profiles/michael"/ "$TEMP_DIR"/

      # Optionally allow overriding the Firefox binary via env var
      FIREFOX_NIGHTLY="''${FIREFOX_NIGHTLY:-/Applications/Firefox Nightly.app/Contents/MacOS/firefox}"
      if [[ ! -x "$FIREFOX_NIGHTLY" ]]; then
        echo "Error: Firefox Nightly executable not found at: $FIREFOX_NIGHTLY" >&2
        exit 1
      fi

      echo "Launching Firefox Nightly with temporary profile..."
      "$FIREFOX_NIGHTLY" --no-remote --profile "$TEMP_DIR"
    '';
  };
}
