{
  self,
  nix-darwin,
  home-manager,
  ...
}:
{
  darwinConfigurations = {
    "michaels-mbp-mozilla" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        (self.lib.mkModule ./configuration.nix { })
        home-manager.darwinModule
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.michael = self.lib.mkModule ./home.nix { };
        }
      ];
    };
  };
}
