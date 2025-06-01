{ pkgs, ... }:
{
  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;

  networking.hostId = "4831eedc";

  environment.systemPackages = [
    pkgs.zfs
  ];
}
