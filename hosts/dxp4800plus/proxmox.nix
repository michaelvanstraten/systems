{ proxmox-nixos, ... }:
_: {
  imports = [
    proxmox-nixos.nixosModules.proxmox-ve
  ];

  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.178.78";
  };

  nixpkgs.overlays = [
    proxmox-nixos.overlays."x86_64-linux"
  ];

  networking.useNetworkd = true;
}
