{ self, ... }:
let
  inherit (self.lib) modulesFromDirectoryRecursive;
in
{
  darwinModules = modulesFromDirectoryRecursive ./darwin;
  homeModules = modulesFromDirectoryRecursive ./home-manager;
  nixosModules = modulesFromDirectoryRecursive ./nixos;
}
