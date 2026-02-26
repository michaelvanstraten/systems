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
    # (self.lib.mkModule ./services { })
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  console.keyMap = "de";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.michael = self.lib.mkModule ./home.nix { };
  };

  nix.remoteBuilder = {
    enable = true;
    supportedFeatures = [
      "kvm"
      "big-parallel"
    ];
  };

  networking.hostName = "dxp4800plus";

  security.sudo.wheelNeedsPassword = false;

  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      # authKeyFile = config.sops.secrets."tailscale/oauth_client_secret".path;
      # authKeyParameters.ephemeral = false;
      extraUpFlags = [
        "--advertise-exit-node"
        "--advertise-tags=tag:server"
      ];
    };

    openssh.enable = true;

    zfs.autoScrub.enable = true;
  };

  system.stateVersion = "25.11";

  users.users.michael = {
    extraGroups = [ "wheel" ];
    initialPassword = "fsbEh&PzR9Eo";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV"
    ];
  };

  time.timeZone = "Europe/Berlin";
}
