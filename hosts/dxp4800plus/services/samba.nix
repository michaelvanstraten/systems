{ ... }:
let
  containerIp = "10.100.0.7";
in
{
  services.newt.blueprint = {
    private-resources = {
      smb = {
        name = "SMB";
        mode = "host";
        destination = containerIp;
        tcp-ports = "445";
        alias = "smb.vanstraten.cloud";
      };
    };
  };

  containers.samba = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/srv/homes" = {
        hostPath = "/tank/homes";
        isReadOnly = false;
      };

      "/srv/media" = {
        hostPath = "/tank/media";
        isReadOnly = false;
      };

      "/srv/timemachine" = {
        hostPath = "/tank/timemachine";
        isReadOnly = false;
      };

      "/var/lib/samba" = {
        hostPath = "/tank/appdata/samba";
        isReadOnly = false;
      };
    };

    config = {
      users.groups = {
        timemachine = { };
        mediashare = { };
      };

      users.users.michael = {
        isNormalUser = true;
        extraGroups = [
          "timemachine"
          "mediashare"
        ];
      };

      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "fruit:aapl" = "yes";
            "server min protocol" = "SMB2";
          };

          homes = {
            "read only" = "no";
            path = "/srv/homes/%U";
            "valid users" = "%S";
            browseable = "no";
            "create mask" = "0700";
            "directory mask" = "0700";
          };

          Media = {
            path = "/srv/media";
            "valid users" = "@mediashare";
            "read only" = "no";
            browseable = "yes";
            comment = "Media Library";
          };

          "Time Machine" = {
            path = "/srv/timemachine/%U";
            "valid users" = "@timemachine";
            "read only" = "no";
            browseable = "yes";
            comment = "Time Machine Backups";
            "vfs objects" = "catia fruit streams_xattr";
            "fruit:time machine" = "yes";
            "fruit:model" = "TimeCapsule6,106";
            "create mask" = "0600";
            "directory mask" = "0700";
          };
        };
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
