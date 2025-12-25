{
  self,
  nixpkgs,
  proxmox-nixos,
  ...
}:
{ pkgs, ... }:
{
  imports = [
    proxmox-nixos.nixosModules.proxmox-ve
  ];

  nixpkgs.overlays = [
    proxmox-nixos.overlays.x86_64-linux
  ];

  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.178.201";
    bridges = [ "br0" ];
  };

  # iGPU passthrough
  hardware.graphics.enable = true;
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "i915"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "vfio-pci.ids=8086:46b3,8086:51c8"
  ];
}
