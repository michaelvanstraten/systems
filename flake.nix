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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      pre-commit-hooks,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    {
      darwinConfigurations = import ./darwinConfigurations { inherit inputs nix-darwin home-manager; };

      nixosConfigurations = import ./nixosConfigurations { inherit inputs nixpkgs; };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Checks pre-commit-hooks
        checks = import ./checks { inherit system pre-commit-hooks pkgs; };

        # Development shell with necessary tools
        devShells =
          let
            pre-commit-check = self.checks.${system}.pre-commit-check;
          in
          {
            default = pkgs.mkShell {
              packages = pre-commit-check.enabledPackages ++ [
                self.formatter.${system}
                # Add other dependencies here
              ];
              inherit (pre-commit-check) shellHook;
            };
          };

        # Formatter for this flake
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
