{ nixpkgs, sops-nix, ... }@args:
let
  inherit (nixpkgs.lib) nixosSystem;

  make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";

  defaultArgs = {
    specialArgs = {
      inherit make-disk-image;
    } // args;
  };
in
{
  h2946065 = nixosSystem (
    defaultArgs
    // {
      modules = [
        ../secrets
        ./hosts/h2946065/configuration.nix
        sops-nix.nixosModules.sops
      ];
    }
  );

  rack-01-k8s-master-nuc-01 = nixosSystem (
    defaultArgs
    // {
      modules = [
        ../secrets
        ./hosts/rack-01/k8s-master-nuc-01.nix
        sops-nix.nixosModules.sops
      ];
    }
  );
}
