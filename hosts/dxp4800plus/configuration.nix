{
  self,
  ...
}:
{ pkgs, ... }:
{
  imports = [
    (self.lib.mkModule ./services { })
    ./zfs.nix
    self.nixosModules.remote-builder
    self.nixosModules.ssh
    self.nixosModules.users
    self.sharedModules.nix
  ];

  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";

  networking.hostName = "dxp4800plus";
  networking.domain = "vanstraten.cloud";

  services.tailscale.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;

  system.stateVersion = "25.11";
}
