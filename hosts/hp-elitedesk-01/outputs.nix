{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.hp-elitedesk-01 = nixosSystem {
    modules = [
      (self.lib.mkModule ./disk-config.nix { })
      (self.lib.mkModule ./hardware-configuration.nix { })
      (self.lib.mkModule ./configuration.nix { })
    ];
  };
}
