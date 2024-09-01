{ ... }:
{
  system.defaults = {
    # Automatically hide and show the Dock
    dock.autohide = true;
    # Set Dock auto hide time modifier
    dock.autohide-time-modifier = 0.7;
    # Disable most recently used spaces in Dock
    dock.mru-spaces = false;
    # Make Dock icons of hidden applications translucent
    dock.showhidden = true;
    # Don't show recent applications in the dock.
    dock.show-recents = false;
    dock.persistent-apps = [
      "/System/Applications/Mail.app/"
      "/Applications/Bitwarden.app/"
      "/System/Applications/Messages.app/"
      "/Applications/WhatsApp.app/"
      "/System/Applications/Calendar.app/"
      "/System/Applications/Reminders.app/"
      "/Applications/Alacritty.app/"
      "/Applications/Firefox Nightly.app/"
      "/System/Applications/System Settings.app/"
    ];
  };
}
