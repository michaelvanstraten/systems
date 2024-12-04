{ self, ... }:
let
  inherit (self.lib) modulesFromDirectoryRecursive;
in
{
  homeModules = modulesFromDirectoryRecursive ./modules;
}
