{ pkgs, ... }:
{
  imports = [
    ../../modules
    ../../modules/hardware/libvirtd.nix
    ./virtual-disk-MBR.nix
  ];

  networking.hostName = "h2946065";

  nixpkgs.hostPlatform = "x86_64-linux";

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

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
