{ self, sops-nix, ... }:
{ ... }:
{
  imports =
    with self.nixosModules;
    [
      personal-cloud
      ssh
      users
    ]
    ++ [
      self.nixosModules."hardware/intel-nuc"
      sops-nix.nixosModules.sops
      self.sharedModules.nix
    ];

  console.keyMap = "de";

  system.stateVersion = "25.11";
}
