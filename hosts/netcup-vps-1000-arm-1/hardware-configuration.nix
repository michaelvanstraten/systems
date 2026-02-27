{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
      "sr_mod"
    ];

    initrd.kernelModules = [ ];

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    extraModulePackages = [ ];

    kernelParams = [
      "console=ttyS0,115200"
      "console=tty1"
    ];

    zfs.devNodes = "/dev/disk/by-path";
  };

  networking.useDHCP = lib.mkDefault true;
}
