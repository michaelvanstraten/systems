{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home.activation.restartDarwinDock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] (
    lib.optionalString (config.targets.darwin.defaults ? "com.apple.dock") ''
      verboseEcho "Restarting macOS Dock"
      ${lib.getExe pkgs.killall} Dock || true
    ''
  );

  targets.darwin = {
    defaults = {
      "NSGlobalDomain" = {
        # Set a faster keyboard repeat rate
        KeyRepeat = 2;
        # Set a shorter delay until key repeat
        InitialKeyRepeat = 15;
        # Enable subpixel font rendering on non-Apple LCDs
        AppleFontSmoothing = 2;
      };

      "com.apple.dock" = {
        autohide = true;
        showhidden = true;
        show-recents = false;
        autohide-time-modifier = 0.7;
        # Show indicator lights for open applications in the Dock
        show-process-indicators = true;
        # Disable most recently used spaces in Dock
        mru-spaces = false;
        # Enable grouping of application windows in Exposé
        expose-group-apps = true;
      };

      "com.apple.AppleMultitouchTrackpad".Clicking = true;

      "com.apple.finder" = {
        ShowPathbar = true;
        _FXSortFoldersFirst = true;
        FXEnableExtensionChangeWarning = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        # Show the Home directory as Default folder
        NewWindowTarget = "PfHm";
        ShowRecentTags = 0;
        SidebarDevicesSectionDisclosedState = 1;
        StandardViewSettings = {
          IconViewSettings = {
            arrangeBy = "kind";
            gridSpacing = 54;
            iconSize = 64;
            labelOnBottom = 1;
            showIconPreview = 1;
            showItemInfo = 0;
            textSize = 12;
            viewOptionsVersion = 1;
          };
        };
      };

      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network volumes
        DSDontWriteNetworkStores = true;
      };

      "com.apple.menuextra.clock" = {
        # Make the menu bar clock include seconds
        DateFormat = "EEE d MMM HH:mm:ss";
      };

      "com.apple.Spotlight" = {
        orderedItems = [
          {
            enabled = 1;
            name = "APPLICATIONS";
          }
          {
            enabled = 1;
            name = "MENU_EXPRESSION";
          }
          {
            enabled = 0;
            name = "CONTACT";
          }
          {
            enabled = 0;
            name = "MENU_CONVERSION";
          }
          {
            enabled = 0;
            name = "MENU_DEFINITION";
          }
          {
            enabled = 0;
            name = "DOCUMENTS";
          }
          {
            enabled = 0;
            name = "EVENT_TODO";
          }
          {
            enabled = 0;
            name = "DIRECTORIES";
          }
          {
            enabled = 0;
            name = "FONTS";
          }
          {
            enabled = 0;
            name = "IMAGES";
          }
          {
            enabled = 0;
            name = "MESSAGES";
          }
          {
            enabled = 0;
            name = "MOVIES";
          }
          {
            enabled = 0;
            name = "MUSIC";
          }
          {
            enabled = 0;
            name = "MENU_OTHER";
          }
          {
            enabled = 0;
            name = "PDF";
          }
          {
            enabled = 0;
            name = "PRESENTATIONS";
          }
          {
            enabled = 0;
            name = "MENU_SPOTLIGHT_SUGGESTIONS";
          }
          {
            enabled = 0;
            name = "SPREADSHEETS";
          }
          {
            enabled = 0;
            name = "SYSTEM_PREFS";
          }
          {
            enabled = 0;
            name = "TIPS";
          }
          {
            enabled = 0;
            name = "BOOKMARKS";
          }
        ];
      };

      "com.theron.UnnaturalScrollWheels" = {
        AlternateDetectionMethod = 0;
        DisableMouseAccel = 0;
        DisableScrollAccel = 1;
        FirstLaunch = 0;
        InvertHorizonalScroll = 0;
        InvertHorizontalScroll = 0;
        InvertVerticalScroll = 1;
        LaunchAtLogin = 1;
        OriginalAccel = 45056;
        ScrollLines = 3;
        ShowMenuBarIcon = 0;
      };
    };
  };

  lib.darwin.mkPersistentApps =
    value:
    if !(lib.isList value) then
      value
    else
      map (app: {
        tile-data = {
          file-data = {
            _CFURLString = app;
            _CFURLStringType = 0;
          };
        };
      }) value;
}
