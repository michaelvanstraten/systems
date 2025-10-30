{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "kvm-intel"
  ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty1"
  ];
  # The default /dev/disk/by-id does not exist
  boot.zfs.devNodes = "/dev/disk/by-path";

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
