{ self, ... }:
let
  inherit (self) homeModules;
in
{ pkgs, ... }:
{
  imports = with homeModules; [
    Alacritty
    Firefox
    Karabiner-Elements.default
    Lazygit
    Poetry
    VSCodium
    darwin.defaults
    darwin.applications
    git
    nvim.default
    sesh
    shells
    starship
    tmux.default
    helix
  ];

  xdg.enable = true;
  home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      wget
      nixd
      stylua
      lua-language-server
      nixfmt-rfc-style
      ltex-ls
      podman
      podman-compose
      tree-sitter
      darwin.trash

      keepassxc
      utm
    ];
  };

  programs = {
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
