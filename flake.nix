{
  nixConfig = {
    experimental-features = [
      "flakes"
      "pipe-operators"
    ];
  };

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nixpkgs = {
      url = "github:NixOs/nixpkgs?ref=nixpkgs-unstable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cyberdream-theme = {
      url = "github:scottmckendry/cyberdream.nvim";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    moz-phab = {
      url = "github:mozilla-conduit/review";
      flake = false;
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      pre-commit-hooks,
      sops-nix,
      ...
    }@inputs:
    let
      inherit ((import ./lib/outputs.nix inputs).lib) callOutputs;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Checks pre-commit-hooks
        checks = import ./checks { inherit pre-commit-hooks system; };

        # Development shell with necessary tools
        devShells =
          let
            pre-commit-check = self.checks.${system}.pre-commit-check;
          in
          {
            default = pkgs.mkShell {
              packages = pre-commit-check.enabledPackages ++ [
                pkgs.just
                (pkgs.nixos-rebuild-ng.overridePythonAttrs { doCheck = false; })
                self.formatter.${system}
                pkgs.sops
                pkgs.ssh-to-age
              ];
              inherit (pre-commit-check) shellHook;
            };
          };

        # Formatter for this flake
        formatter = pkgs.nixfmt;
      }
    )
    // callOutputs {
      directory = ./.;
      inherit inputs;
    };
}
