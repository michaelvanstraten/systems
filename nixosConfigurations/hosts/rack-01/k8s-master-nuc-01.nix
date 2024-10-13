{ nixosModules, ... }:
{
  imports = with nixosModules; [
    format.raw-efi
    hardware.intel-nuc
    nix
    roles.k8s-master
    ssh
    users
  ];

  console.keyMap = "de";

  networking.hostName = "rack-01-k8s-master-nuc-01";

  system.stateVersion = "25.11";
}
