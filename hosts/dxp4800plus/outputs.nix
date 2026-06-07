{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.dxp4800plus = nixosSystem {
    modules = [
      (self.lib.mkModule ./disk-config.nix { })
      (self.lib.mkModule ./hardware-configuration.nix { })
      (self.lib.mkModule ./configuration.nix { })
    ];
  };
}
