{
  self,
  nixpkgs,
  nixos-generators,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.dxp4800plus = nixosSystem {
    modules = [
      (self.lib.mkModule ./configuration.nix { })
      ./hardware-configuration.nix
    ];
  };

  packages.x86_64-linux = {
    dxp4800plus-raw-efi-image = nixos-generators.nixosGenerate {
      modules = [
        (self.lib.mkModule ./configuration.nix { })
      ];
      format = "raw-efi";
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };
  };
}
