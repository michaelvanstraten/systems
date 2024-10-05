{ nixpkgs, ... }:
let
  modules = nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
    callPackage = modulePath: _: import modulePath;
    directory = ./.;
  };

  cleanedModules = nixpkgs.lib.filterAttrs (moduleName: _: moduleName != "default") modules;
in
cleanedModules
