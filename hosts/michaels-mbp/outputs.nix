{ nix-darwin, home-manager, ... }@inputs:
{
  darwinConfigurations = {
    "michaels-mbp" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModule
        (import ./configuration.nix inputs)
      ];
    };
  };
}
