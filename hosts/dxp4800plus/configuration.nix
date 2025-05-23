{
  self,
  ...
}:
{ pkgs, ... }:
{
  imports = [
    (self.lib.mkModule ./proxmox.nix { })
    (self.lib.mkModule ./automated-ripping-machine { })
    self.nixosModules.remote-builder
    self.nixosModules.ssh
    self.nixosModules.users
    self.sharedModules.nix
    self.nixosModules."hardware/ugreen-nasync-serie"
  ];

  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";

  networking.hostName = "dxp4800plus";
  networking.domain = "vanstraten.cloud";

  services.tailscale.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.zfs.extraPools = [ "tank" ];

  nix.remoteBuilder.enable = true;
  nix.remoteBuilder.supportedFeatures = [
    "kvm"
    "big-parallel"
  ];

  services.automated-ripping-machine.enable = true;

  # ZFS stuff
  environment.systemPackages = [ pkgs.zfs ];
  services.zfs.autoScrub.enable = true;

  system.stateVersion = "25.11";
}
