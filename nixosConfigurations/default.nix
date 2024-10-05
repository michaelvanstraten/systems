{
  inputs,
  self,
  nixpkgs,
  nixosModules ? self.nixosModules,
  disko ? inputs.disko,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;

  defaultArgs = {
    specialArgs = {
      make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
      inherit disko nixosModules;
    };
  };

in
{
  h2946065 = nixosSystem (defaultArgs // { modules = [ ./hosts/h2946065/configuration.nix ]; });

  rack-01-k8s-master-nuc-01 = nixosSystem (
    defaultArgs // { modules = [ ./hosts/rack-01/k8s-master-nuc-01.nix ]; }
  );
}
