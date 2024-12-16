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
        home-manager.darwinModule
        (self.lib.mkModule ./configuration.nix { })
      ];
    };
  };
}
