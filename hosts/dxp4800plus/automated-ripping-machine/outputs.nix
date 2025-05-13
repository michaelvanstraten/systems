{
  pyproject-nix,
  flake-utils,
  nixpkgs,
  ...
}:
flake-utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages = {
      # Main ARM package
      arm = pkgs.python3Packages.callPackage ./package.nix { inherit pyproject-nix; };

      # Standalone pydvdid package
      pydvdid = pkgs.python3Packages.callPackage ./pydvdid.nix { };
    };
  }
)
