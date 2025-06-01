{ proxmox-nixos, ... }:
{ lib, ... }:
{
  imports = [ proxmox-nixos.nixosModules.proxmox-ve ];

  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.178.88";
  };

  nixpkgs.overlays = [
    proxmox-nixos.overlays.x86_64-linux
  ];

  networking.useNetworkd = true;

  networking.bridges.vmbr0.interfaces = [ "enp6s0" ];
  networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
}
