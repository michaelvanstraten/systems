{ nixpkgs, sops-nix, ... }@inputs:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.h2946065 = nixosSystem {
    modules = [
      sops-nix.nixosModules.sops
      (import ./configuration.nix inputs)
      ../../secrets
    ];
  };
}
