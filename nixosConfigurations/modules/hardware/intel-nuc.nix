{ lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    growPartition = true;
    kernelParams = [ "console=tty0" ];
    initrd.availableKernelModules = [ "uas" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  boot.loader = {
    timeout = lib.mkDefault 3;
    grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };
}
