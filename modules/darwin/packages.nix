{ nixpkgs-firefox-darwin, ... }:
{ ... }:
{
  nixpkgs = {
    overlays = [ nixpkgs-firefox-darwin.overlay ];
  };
}
