{ pkgs, ... }:
{
  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    extraPools = [ "tank" ];
    forceImportRoot = false;
  };

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_rsa_key"
        "/etc/secrets/initrd/ssh_host_ed25519_key"
      ];
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV"
      ];
    };
    postCommands = ''
      zpool import zpool
      # Add the load-key command to the .profile
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };

  environment.systemPackages = [
    pkgs.zfs
  ];

  services.zfs.autoScrub.enable = true;
}
