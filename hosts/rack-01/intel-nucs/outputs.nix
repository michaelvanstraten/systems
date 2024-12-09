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
  nixosConfigurations =
    builtins.mapAttrs
      (
        hostname: module:
        nixosSystem {
          modules = [
            { networking.hostName = hostname; }
            nixos-generators.nixosModules.raw-efi
            ../../../secrets
            (import ./configuration.nix inputs)
            module
          ];
        }
      )
      {
        "rack-01-nuc-01" = {
          imports = [
            self.nixosModules.roles.k8s-master
          ];
        };
        "rack-01-nuc-02" = { };
        "rack-01-nuc-03" = { };
      };
}
