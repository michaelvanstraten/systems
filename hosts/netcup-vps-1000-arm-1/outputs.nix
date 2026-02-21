{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs.lib) nixosSystem;
in
{
  nixosConfigurations.netcup-vps-1000-arm-1 = nixosSystem {
    modules = [
      (
        { config, ... }:
        {
          imports = [
            self.nixosModules.all
            self.sharedModules.all
            (self.lib.mkModule ./disko.nix { })
            ./hardware-configuration.nix
          ];

          boot.loader.systemd-boot.enable = true;

          console.keyMap = "de";

          networking.hostId = "178054be";
          networking.hostName = "netcup-vps-1000-arm-1";

          nixpkgs.hostPlatform = "aarch64-linux";

          security.sudo.wheelNeedsPassword = false;

          services.openssh.enable = true;

          users.users.michael = {
            isNormalUser = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV michael@macbook-pro"
            ];
            password = "";
            extraGroups = [ "wheel" ];
          };

          time.timeZone = "Europe/Berlin";

          system.stateVersion = "25.11";

          services = {
            # tailscale = {
            #   enable = true;
            #   useRoutingFeatures = "both";
            #   authKeyFile = config.sops.secrets."tailscale/oauth_client_secret".path;
            #   authKeyParameters.ephemeral = false;
            #   extraUpFlags = [
            #     "--advertise-exit-node"
            #     "--advertise-tags=tag:server"
            #   ];
            # };
          };

          services.k3s.enable = true;
          services.k3s.serverAddr = "https://netcup-vps-1000-arm-1:6443";

        }
      )
    ];
  };
}
