{ ... }:
{
  imports = [
    ./minimal.nix

    ../modules/Alacritty.nix
    ../modules/Karabiner-Elements
    ../modules/Poetry.nix
    ../modules/VSCodium.nix
    ../modules/Firefox.nix
  ];

  home.username = "mozilla";

  programs = {
    firefox = {
      enable = false;
    };

    git = {
      userName = "Michael van Straten";
      userEmail = "mvanstraten@mozilla.com";
    };

    jq.enable = true;
  };
}
