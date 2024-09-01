{ inputs, pkgs, ... }:
{
  nixpkgs = {
    overlays = with inputs; [ nixpkgs-firefox-darwin.overlay ];
  };

  environment.systemPackages = with pkgs; [
    monitorcontrol
    unnaturalscrollwheels

    alacritty

    vscodium

    firefox-bin
    # chromium
  ];
}
