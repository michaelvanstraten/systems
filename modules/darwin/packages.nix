{ nixpkgs-firefox-darwin, ... }:
{ pkgs, ... }:
{
  nixpkgs = {
    overlays = [ nixpkgs-firefox-darwin.overlay ];
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
