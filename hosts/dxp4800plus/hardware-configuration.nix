{ self, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "ahci"
    "usbhid"
    "uas"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiInstallAsRemovable = true;
    efiSupport = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C8A3-7CAA";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  imports = [ self.nixosModules."hardware/ugreen-nasync-serie" ];

  networking.hostId = "4831eedc";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.powertop.enable = true;
}
