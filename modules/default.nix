{ nixpkgs, ... }:
let
  modulesFromDirectoryRecursive =
    directory:
    nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = modulePath: _: import modulePath;
      inherit directory;
    };
in
{
  darwinModules = modulesFromDirectoryRecursive ./darwin;
  homeModules = modulesFromDirectoryRecursive ./home-manager;
  nixosModules = modulesFromDirectoryRecursive ./nixos;
}
