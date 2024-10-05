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

  _module.args.nixinate = {
    host = "tarox-1";
    sshUser = "michael";
    buildOn = "remote";
    substituteOnTarget = true;
    hermetic = false;
  };

  system.stateVersion = "25.11";
}
