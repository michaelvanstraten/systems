{ lib, pkgs, ... }:
let
  containerIp = "10.100.0.3";
in
{
  nixpkgs.config.allowUnfree = true; # Needed for drivers

  services.newt.blueprint = {
    private-resources = {
      jellyfin = {
        name = "Jellyfin";
        mode = "http";
        destination = containerIp;
        destination-port = 8096;
        full-domain = "jellyfin.vanstraten.cloud";
        ssl = true;
        scheme = "http";
      };
    };
  };

  containers.jellyfin = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "${containerIp}/24";

    allowedDevices = [
      {
        node = "/dev/dri/card0";
        modifier = "rw";
      }
      {
        node = "/dev/dri/renderD128";
        modifier = "rw";
      }
    ];

    bindMounts = {
      "/dev/dri/card0" = {
        hostPath = "/dev/dri/card0";
        isReadOnly = false;
      };
      "/dev/dri/renderD128" = {
        hostPath = "/dev/dri/renderD128";
        isReadOnly = false;
      };

      "/srv/media" = {
        hostPath = "/tank/media";
        isReadOnly = true;
      };

      "/var/lib/jellyfin" = {
        hostPath = "/tank/appdata/jellyfin";
        isReadOnly = false;
      };
      "/var/cache/jellyfin" = {
        hostPath = "/tank/appdata/jellyfin-cache";
        isReadOnly = false;
      };
    };

    config = {
      hardware.graphics = {
        enable = true;

        extraPackages = with pkgs; [
          intel-ocl
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];
      };

      environment.systemPackages = [
        pkgs.libva-utils
      ];

      users.users.jellyfin.extraGroups = [
        "video"
        "render"
      ];

      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };

      systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      networking = {
        useNetworkd = true;
        useHostResolvConf = false;
        nameservers = [
          "8.8.8.8"
          "1.1.1.1"
        ];
      };

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Address = "${containerIp}/24";
          Gateway = "10.100.0.1";
          DHCP = "no";
          LinkLocalAddressing = "no";
        };
      };

      system.stateVersion = "26.05";
    };
  };
}
