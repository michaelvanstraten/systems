{ nixpkgs, ... }:
let
  lib = nixpkgs.lib;
  hostConfigurations = lib.filesystem.listFilesRecursive ./hosts;
in
lib.mergeAttrsList (
  builtins.map (
    hostConfiguration:
    let
      nixosConfiguration = nixpkgs.lib.nixosSystem {
        modules = [ hostConfiguration ];
        specialArgs = {
          make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
        };
      };
    in
    {
      ${nixosConfiguration.config.networking.hostName} = nixosConfiguration;
    }
  ) hostConfigurations
)
