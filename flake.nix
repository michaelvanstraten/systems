{
  nixConfig = {
    experimental-features = [
      "flakes"
      "pipe-operators"
    ];
  };

  inputs = {
    BetterFox = {
      url = "github:yokoffing/BetterFox";
      flake = false;
    };

    cyberdream-theme = {
      url = "github:scottmckendry/cyberdream.nvim";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs = {
      url = "github:NixOs/nixpkgs?ref=nixpkgs-unstable";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil_ls = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos?rev=91c96a414e14835b84adbf775f793739a5851fab";

    moz-phab = {
      url = "github:mozilla-conduit/review";
      flake = false;
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      pre-commit-hooks,
      nil_ls,
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
        checks = import ./checks { inherit pre-commit-hooks system nil_ls; };

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
              ];
              inherit (pre-commit-check) shellHook;
            };
          };

        # Formatter for this flake
        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // callOutputs {
      directory = ./.;
      inherit inputs;
    };
}
