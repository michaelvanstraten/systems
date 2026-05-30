{
  self,
  home-manager,
  sops-nix,
  ...
}:
{ config, pkgs, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
    self.nixosModules.all
    self.sharedModules.all
    sops-nix.nixosModules.sops
    ./networking.nix
    ./services/jellyfin.nix
    (self.lib.mkModule ./services/newt.nix { })
    ./services/proxy-sidecar.nix
    ./services/seedbox.nix
    ./services/nextcloud
    ./services/paperless
    (self.lib.mkModule ./vms { })
  ];

  system.stateVersion = "25.11";

  networking = {
    hostId = "4831eedc"; # Required for ZFS
    hostName = "dxp4800plus";
  };

  time.timeZone = "Europe/Berlin";

  console.keyMap = "de";

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    zfs.extraPools = [ "tank" ];
  };

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "fsbEh&PzR9Eo";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV"
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

    zfs.autoScrub.enable = true;
  };

  nix.remoteBuilder = {
    enable = true;
    supportedFeatures = [
      "kvm"
      "big-parallel"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.michael = self.lib.mkModule ./home.nix { };
  };
}
