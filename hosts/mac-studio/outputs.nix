{ self, nix-darwin, ... }:
{
  darwinConfigurations = {
    "fxe-mac-studio-01" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ (self.lib.mkModule ./configuration.nix { }) ];
    };
  };
}
