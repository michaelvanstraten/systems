{ nix-darwin, home-manager, ... }@args:

{
  "MacBook-Pro-von-Michael" = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      home-manager.darwinModule
      hosts/personal-macbook-pro.nix
    ];
    specialArgs = args;
  };
  "N7R221P6V5" = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      home-manager.darwinModule
      hosts/mozilla-macbook-pro.nix
    ];
    specialArgs = args;
  };
}
