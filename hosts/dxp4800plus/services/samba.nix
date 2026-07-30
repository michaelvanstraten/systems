{ lib, ... }:
let
  containerIp = "10.100.0.7";

  sambaUsers = {
    michael = [
      "timemachine"
      "media"
    ];
    uwe = [
      "timemachine"
    ];
  };
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
        users = [ "uwe@vanstraten.de" ];
      };
    };
  };

  containers.samba = {
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
        media.gid = 1500;
      };

      users.users = lib.mapAttrs (_: extraGroups: {
        isNormalUser = true;
        inherit extraGroups;
      }) sambaUsers;

      systemd.tmpfiles.settings."10-samba-user-dirs" = lib.concatMapAttrs (
        user: extraGroups:
        {
          "/srv/homes/${user}".d = {
            inherit user;
            group = "users";
            mode = "0700";
          };
        }
        // lib.optionalAttrs (lib.elem "timemachine" extraGroups) {
          "/srv/timemachine/${user}".d = {
            inherit user;
            group = "timemachine";
            mode = "0700";
          };
        }
      ) sambaUsers;

      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "fruit:aapl" = "yes";
            "server min protocol" = "SMB2";
            "host msdfs" = "no";
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
            "valid users" = "@media";
            "read only" = "no";
            browseable = "yes";
            comment = "Media Library";
            "force group" = "media";
            "create mask" = "0664";
            "force create mode" = "0664";
            "directory mask" = "2775";
            "force directory mode" = "2775";
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
    };
  };
}
