{ ... }:
{
  imports = [
    ../../modules
    ../../modules/hardware/intel-nuc.nix
    ../../modules/roles/k8s-master.nix
    ../../modules/format/raw-efi.nix
  ];

  networking.hostName = "rack-01-k8s-master-nuc-01";

  _module.args.nixinate = {
    host = "tarox-1";
    sshUser = "michael";
    buildOn = "remote";
    substituteOnTarget = true;
    hermetic = false;
  };
}
