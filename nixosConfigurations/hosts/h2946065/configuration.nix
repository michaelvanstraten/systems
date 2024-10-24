{ nixosModules, pkgs, ... }:
{
  imports = with nixosModules; [
    ./virtual-disk-MBR.nix
    hardware.libvirtd
    nix
    personal-cloud
    ssh
    users
  ];

  networking.hostName = "h2946065";

  console.keyMap = "de";

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 80;
  };

  users.users.michael.extraGroups = [ "docker" ];

  virtualisation.docker.enable = true;

  networking.firewall.enable = false;

  environment.systemPackages = [ pkgs.docker-compose ];

  time.timeZone = "Europe/Berlin";

  system.stateVersion = "25.11";
}
