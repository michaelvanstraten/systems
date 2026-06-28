{
  nixConfig = {
    experimental-features = [
      "flakes"
      "pipe-operators"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://zed-industries.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "zed-industries.cachix.org-1:fgVpvtdF+ssrgP1lB6EusuR3uM6bNcncWduKxri3u6Y="
    ];
  };

  inputs = {
    nixpkgs = {
      url = "github:NixOs/nixpkgs?ref=nixos-unstable";
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

    cyberdream-theme = {
      url = "github:scottmckendry/cyberdream.nvim";
      flake = false;
    };

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

    authentik-nix.url = "github:nix-community/authentik-nix?ref=version/2026.2.3";

    microvm.url = "github:microvm-nix/microvm.nix";

    fosrl-newt.url = "github:fosrl/newt?ref=1.12.5";

    private-patches = {
      url = "github:michaelvanstraten/private-patches";
      flake = false;
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pre-commit-hooks,
      sops-nix,
      ...
    }@inputs:
    let
      inherit ((import ./lib/outputs.nix inputs).lib) forAllSystems callOutputs;
    in
    {
      # Checks pre-commit-hooks
      checks = forAllSystems (
        pkgs:
        import ./checks {
          inherit
            pre-commit-hooks
            ;
          inherit (pkgs.stdenv) system;
        }
      );

      # Development shell with necessary tools
      devShells = forAllSystems (
        pkgs:
        let
          pre-commit-check = self.checks.${pkgs.stdenv.system}.pre-commit-check;
        in
        {
          default = pkgs.mkShell {
            packages = pre-commit-check.enabledPackages ++ [
              pkgs.just
              pkgs.nixos-rebuild
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.gnupg
              pkgs.yubikey-manager
              pkgs.yubikey-personalization
            ];
            inherit (pre-commit-check) shellHook;
          };
        }
      );

      # Formatter for this flake
      formatter = forAllSystems (
        pkgs:
        let
          inherit (self.checks.${pkgs.stdenv.system}.pre-commit-check.config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );
    }
    |> nixpkgs.lib.recursiveUpdate (callOutputs {
      directory = ./.;
      inherit inputs;
    });
}
