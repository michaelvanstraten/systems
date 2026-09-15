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
    (self.lib.mkModule ./services/newt.nix { })
  ];

  system.stateVersion = "25.11";

  internal.sshAccess.enable = true;

  time.timeZone = "Europe/Berlin";

  console.keyMap = "de";

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 32;
    };
  };

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  sops.defaultSopsFile = ./secrets.yaml;

  services = {
    openssh.enable = true;
    openssh.openFirewall = true;
    zfs.autoScrub.enable = true;
    fwupd.enable = true;
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
