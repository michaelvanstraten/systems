{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixinate = {
      url = "github:matthewcroughan/nixinate";
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
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      nixinate,
      nix-darwin,
      home-manager,
      self,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          lib = nixpkgs.lib;
          hostConfigurations = lib.filesystem.listFilesRecursive ./nixos/hosts;
        in
        lib.mergeAttrsList (
          builtins.map (
            hostConfiguration:
            let
              nixosConfiguration = nixpkgs.lib.nixosSystem {
                modules = [ hostConfiguration ];
                specialArgs = {
                  make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
                };
              };
            in
            {
              ${nixosConfiguration.config.networking.hostName} = nixosConfiguration;
            }
          ) hostConfigurations
        );

      # apps = nixinate.nixinate.aarch64-linux self;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              nil.enable = true;
              prettier = {
                enable = true;
                settings = {
                  prose-wrap = "always";
                };
              };
            };
          };
        };

        devShells = {
          default = pkgs.mkShell {
            inherit (checks.pre-commit-check) shellHook;
            buildInputs = checks.pre-commit-check.enabledPackages;
          };
        };
      }
    );
}
