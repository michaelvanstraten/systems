{
  self,
  home-manager,
  ...
}:
{ config, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    self.nixosModules.all
    self.sharedModules.all
    ./networking.nix
    ./services/pangolin.nix
  ];

  system.stateVersion = "25.11";

  networking = {
    hostId = "178054be";
    hostName = "netcup-vps-1000-arm-1";
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  time.timeZone = "Europe/Berlin";

  console.keyMap = "de";

  boot.loader.systemd-boot.enable = true;

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV michael@macbook-pro"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  sops.defaultSopsFile = ./secrets.yaml;

  services = {
    openssh.enable = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraUpFlags = [
        "--advertise-exit-node"
        "--advertise-tags=tag:server"
      ];
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.michael = self.lib.mkModule ./home.nix { };
  };
}
