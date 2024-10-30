let
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
  };
in
{
  targets.darwin = {
    inherit defaults;
  };
}
