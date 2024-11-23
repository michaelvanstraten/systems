{ self, sops-nix, ... }:
{ ... }:
{
  imports =
    with self.nixosModules;
    [
      hardware.intel-nuc
      nix
      personal-cloud
      ssh
      users
    ]
    ++ [ sops-nix.nixosModules.sops ];

  console.keyMap = "de";

  system.stateVersion = "25.11";
}
