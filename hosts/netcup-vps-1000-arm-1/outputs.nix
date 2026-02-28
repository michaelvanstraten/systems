{
  self,
  nixpkgs,
  sops-nix,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.netcup-vps-1000-arm-1 = nixosSystem {
    modules = [
      sops-nix.nixosModules.sops
      (self.lib.mkModule ./disko.nix { })
      ./hardware-configuration.nix
      (self.lib.mkModule ./configuration.nix { })
    ];
  };
}
