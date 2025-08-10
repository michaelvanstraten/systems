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
      (self.lib.mkModule ./configuration.nix { })
      (self.lib.mkModule ./disko.nix { })
      (self.lib.mkModule ./hardware-configuration.nix { })
    ];
  };
}
