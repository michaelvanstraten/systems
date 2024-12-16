{ self, sops-nix, ... }:
{ ... }:
{
  imports =
    with self.nixosModules;
    [
      nix
      personal-cloud
      ssh
      users
    ]
    ++ [
      self.nixosModules."hardware/intel-nuc"
      sops-nix.nixosModules.sops
    ];

  console.keyMap = "de";

  system.stateVersion = "25.11";
}
