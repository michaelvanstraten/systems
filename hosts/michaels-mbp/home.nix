{ self, ... }:
{ pkgs, ... }:
{
  imports =
    with self.homeModules;
    [
      Alacritty
      Firefox
      Karabiner-Elements
      Lazygit
      Poetry
      VSCodium
      git
      nvim
      sesh
      shells
      starship
      tmux
    ]
    ++ [
      self.homeModules."darwin/defaults"
      self.homeModules."darwin/applications"
      self.homeModules."darwin/defaultbrowser"
    ];

  xdg.enable = true;
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      wget
      podman
      podman-compose
      darwin.trash

      keepassxc
      utm
    ];
  };

  programs = {
    firefox.package = pkgs.firefox-bin;

    sesh.enable = true;

    thefuck.enable = true;

    direnv.enable = true;

    zoxide.enable = true;
    zoxide.options = [ "--cmd j" ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      userName = "Michael van Straten";
      userEmail = "michael@vanstraten.de";
    };

    bat.enable = true;

    jq.enable = true;
  };

  targets.darwin.defaultbrowser = "firefox";

  targets.darwin.defaults."com.apple.dock".persistent-apps = self.lib.darwin.mkPersistentApps [
    "/System/Applications/Mail.app/"
    "${pkgs.signal-desktop}/Applications/Signal.app/"
    "/System/Applications/Messages.app/"
    "/Applications/WhatsApp.app/"
    "/System/Applications/Reminders.app/"
    "/System/Applications/Calendar.app/"
    "${pkgs.alacritty}/Applications/Alacritty.app/"
    "${pkgs.firefox-bin}/Applications/Firefox.app/"
    "/Applications/Bitwarden.app/"
    "/System/Applications/System Settings.app/"
  ];
}
