{ self, nix-darwin, ... }:
{
  darwinConfigurations = {
    "macbook-pro-mozilla" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ (self.lib.mkModule ./configuration.nix { }) ];
    };
  };
}
