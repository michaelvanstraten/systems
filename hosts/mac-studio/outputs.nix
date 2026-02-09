{ self, nix-darwin, ... }:
{
  darwinConfigurations = {
    "michael-mac-studio" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ (self.lib.mkModule ./configuration.nix { }) ];
    };
  };
}
