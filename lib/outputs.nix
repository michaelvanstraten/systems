{ nixpkgs, ... }@inputs:
{
  lib = {
    callOutputs = import ./callOutputs.nix inputs;
    forAllSystems =
      function:
      with nixpkgs;
      (lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ])
        (
          system:
          function (
            import nixpkgs {
              inherit system;
            }
          )
        );
  };
}
