{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    lazy2nix.url = "github:michaelvanstraten/lazy2nix/";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      lazy2nix,
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.default =
        ((lazy2nix.lib { pkgs = import nixpkgs { inherit system; }; }).mkNeovimConfiguration {
          configDir = ./.;
        }).neovim;
    });
}
