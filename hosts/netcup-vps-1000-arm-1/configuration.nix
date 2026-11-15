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
    (self.lib.mkModule ./services/authentik { })
    (self.lib.mkModule ./services/newt.nix { })
    (self.lib.mkModule ./services/pangolin.nix { })
    ./services/monitoring.nix
    ./services/tor-relay.nix
  ];

  system.stateVersion = "25.11";

  internal.sshAccess.enable = true;

  networking = {
    hostId = "178054be";
    hostName = "netcup-vps-1000-arm-1";
    firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
  };

  time.timeZone = "Europe/Berlin";

  console.keyMap = "de";

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 8;
    };
    zfs.forceImportRoot = false;
  };

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
    openssh.openFirewall = false;

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraSetFlags = [ "--accept-dns=false" ];
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
