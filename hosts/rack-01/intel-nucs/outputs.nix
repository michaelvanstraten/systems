{
  nixos-generators,
  nixpkgs,
  self,
  ...
}:
{
  nixosConfigurations =
    builtins.mapAttrs
      (
        hostname: module:
        nixpkgs.lib.nixosSystem {
          modules = [
            { networking.hostName = hostname; }
            nixos-generators.nixosModules.raw-efi
            ../../../secrets
            (self.lib.mkModule ./configuration.nix { })
            module
          ];
        }
      )
      {
        "rack-01-nuc-01" = {
          imports = [
            self.nixosModules."roles/k8s-master"
          ];
        };
        "rack-01-nuc-02" = { };
        "rack-01-nuc-03" = { };
      };
}
