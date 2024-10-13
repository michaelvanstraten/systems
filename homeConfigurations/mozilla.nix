{
  homeModules,
  pkgs,
  lib,
  ...
}:
{
  imports = with homeModules; [
    Alacritty
    darwin.defaults
    Karabiner-Elements.default
    Poetry
    VSCodium
    Firefox
    git
    nvim.default
    Lazygit
    starship
    sesh
    shells
    tmux.default
  ];

  xdg.enable = true;
  home = {
    sessionVariables = {
      EDITOR = "nvim";
    };
    stateVersion = "24.05";
    shellAliases = {
      ls = "eza";
    };

    packages = with pkgs; [
      wget
      nil
      stylua
      lua-language-server
      nixfmt-rfc-style
      firefox-bin
      ltex-ls
      podman
      podman-compose
      nodejs_22
      tree-sitter
    ];
  };

  programs = {
    eza.enable = true;

    sesh.enable = true;

    thefuck.enable = true;

    zoxide.enable = true;
    zoxide.options = [ "--cmd cd" ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      userName = "Michael van Straten";
      userEmail = "mvanstraten@mozilla.com";
    };

    bat.enable = true;

    jq.enable = true;
  };

  targets.darwin.defaults."com.apple.dock".persistent-apps =
    (homeModules.darwin.utils { inherit lib; }).mkPersistentApps
      [
        # Add wanted items back to the dock
        "/System/Applications/Mail.app/"
        "/System/Applications/Calendar.app/"
        "/System/Applications/Reminders.app/"
        "/Applications/Alacritty.app/"
        "/Applications/Firefox Nightly.app/"
        "/System/Applications/System Settings.app/"
      ];
}
