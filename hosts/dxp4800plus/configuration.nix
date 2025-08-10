{
  self,
  ...
}:
{ config, pkgs, ... }:
{
  imports = [
    self.nixosModules.all
    self.sharedModules.all
    (self.lib.mkModule ./services { })
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  console.keyMap = "de";

  environment.systemPackages = [ pkgs.zfs ];

  nix.remoteBuilder = {
    enable = true;
    supportedFeatures = [
      "kvm"
      "big-parallel"
    ];
    authorizedKeys = [
      (builtins.readFile ../macbook-pro/secrets/nixremote-ssh-key.pub)
    ];
  };

  networking.hostName = "dxp4800plus";

  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = config.sops.secrets."tailscale/oauth_client_secret".path;
      authKeyParameters.ephemeral = false;
      extraUpFlags = [
        "--advertise-exit-node"
        "--advertise-tags=tag:server"
      ];
    };

    openssh.enable = true;

    zfs.autoScrub.enable = true;
  };

  system.stateVersion = "25.11";

  time.timeZone = "Europe/Berlin";
}
