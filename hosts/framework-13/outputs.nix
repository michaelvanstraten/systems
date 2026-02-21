{
  self,
  nixpkgs,
  home-manager,
  nixos-hardware,
  ...
}:
{
  nixosConfigurations.framework-13 = nixpkgs.lib.nixosSystem {
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      ./gaming.nix
      nixos-hardware.nixosModules.framework-amd-ai-300-series
      self.nixosModules.all
      self.sharedModules.all
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.michael = self.lib.mkModule ./home.nix { };
        };
      }
    ];
  };
}
