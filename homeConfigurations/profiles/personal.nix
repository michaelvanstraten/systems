{ lib, ... }:
{
  imports = [
    ./minimal.nix

    ../modules/Alacritty.nix
    ../modules/darwin
    ../modules/Karabiner-Elements
    ../modules/Poetry.nix
    ../modules/VSCodium.nix
    ../modules/Firefox.nix
  ];

  home.username = "michaelvanstraten";
  home.homeDirectory = "/Users/michaelvanstraten";

  targets.darwin.defaults."com.apple.dock".persistent-apps =
    (import ../modules/darwin/utils.nix { inherit lib; }).mkPersistentApps
      [
        # Add wanted items back to the dock
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

  programs = {
    firefox = {
      enable = true;
    };

    git = {
      userName = "Michael van Straten";
      userEmail = "michael@vanstraten.de";
    };

    jq.enable = true;
  };
}
