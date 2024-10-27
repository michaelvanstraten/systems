{ self, nixpkgs, ... }:
let
  inherit (nixpkgs.lib.filesystem) packagesFromDirectoryRecursive;
  inherit (self.lib) callModule;
in
directory:
packagesFromDirectoryRecursive {
  callPackage = callModule;
  inherit directory;
}
