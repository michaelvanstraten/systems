{
  self,
  nix-darwin,
  home-manager,
  ...
}:
{
  darwinConfigurations = {
    "michaels-mbp" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        (self.lib.mkModule ./configuration.nix { })
        home-manager.darwinModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.michaelvanstraten = self.lib.mkModule ./home.nix { };
        }
      ];
    };
  };
}
