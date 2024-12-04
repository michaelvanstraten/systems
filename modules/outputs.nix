{ self, ... }:
let
  inherit (self.lib) modulesFromDirectoryRecursive;
in
{
  darwinModules = modulesFromDirectoryRecursive ./darwin;
  nixosModules = modulesFromDirectoryRecursive ./nixos;
}
