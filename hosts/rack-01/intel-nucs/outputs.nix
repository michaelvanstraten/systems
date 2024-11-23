{
  nixos-generators,
  nixpkgs,
  self,
  ...
}@inputs:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations = builtins.mapAttrs (
    hostname: isMaster:
    nixosSystem {
      modules = [
        nixos-generators.nixosModules.raw-efi
        (if isMaster then self.nixosModules.roles.k8s-master else self.nixosModules.roles.k8s-worker)
        ../../../secrets
        (import ./configuration.nix inputs)
        { networking.hostName = hostname; }
      ];
    }
  ) { "rack-01-k8s-master-nuc-01" = true; };
}
