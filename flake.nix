{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cyberdream-theme = {
      url = "github:scottmckendry/cyberdream.nvim";
      flake = false;
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      nix-darwin,
      home-manager,
      pre-commit-hooks,
      self,
      ...
    }@inputs:
    {
      darwinConfigurations = import ./darwinConfigurations { inherit inputs nix-darwin home-manager; };

      nixosConfigurations = import ./nixosConfigurations { inherit nixpkgs; };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        checks = import ./checks { inherit system pre-commit-hooks pkgs; };

        devShells = {
          default = pkgs.mkShell {
            inherit (checks.pre-commit-check) shellHook;
            buildInputs = checks.pre-commit-check.enabledPackages;
          };
        };
      }
    );
}
