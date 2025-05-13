{
  self,
  pyproject-nix,
  ...
}:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.automated-ripping-machine;

  arm-pkg = pkgs.python3Packages.callPackage ./package.nix { inherit pyproject-nix; };

  settingsFormat = pkgs.formats.yaml { };

  readYAML = pkgs.callPackage ./read-yaml.nix { };

  settingsFile = settingsFormat.generate "arm.yaml" (
    lib.mergeAttrsList [
      # ARM needs default values
      (readYAML "${arm-pkg}/share/arm/setup/arm.yaml")
      (cfg.settings or { })
      {
        INSTALLPATH = "${arm-pkg}/lib/python3.12/site-packages/";
        WEBSERVER_IP = "0.0.0.0"; # Bind to all interfaces
        WEBSERVER_PORT = cfg.port; # Use the configured port
      }
    ]
  );
in
{
  options = {
    services.automated-ripping-machine = {
      enable = lib.mkEnableOption "automated-ripping-machine";

      user = lib.mkOption {
        type = lib.types.str;
        default = "arm";
        description = "User to run the ARM service";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "arm";
        description = "Group to run the ARM service";
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        description = "Additional settings for ARM";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for the ARM web interface";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
      createHome = true;
      extraGroups = [ "cdrom" ];
    };

    users.groups.${cfg.group} = { };

    # Set up udev rules for ARM
    services.udev.extraRules =
      let
        armWrapperScript = "${arm-pkg}/share/arm/scripts/thickclient/arm_wrapper.sh";
      in
      ''
        # udev rules for Automatic Ripping Machine
        ACTION=="change", SUBSYSTEM=="block", RUN+="${armWrapperScript} %k"

      '';

    systemd.services.armui = {
      description = "Automatic Ripping Machine UI Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = 30;
        ExecStart = "${arm-pkg}/bin/arm";
      };
    };

    # Configure network access and firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    environment.etc = {
      "arm/config/abcde.conf".source = "${arm-pkg}/share/arm/setup/.abcde.conf";
      "arm/config/apprise.yaml".source = "${arm-pkg}/share/arm/setup/apprise.yaml";
      "arm/config/arm.yaml".source = settingsFile;
    };

    system.activationScripts.arm-scripts = ''
      # Create scripts directory
      mkdir -p /opt/arm/setup

      # This file needs to exist as a writable destination
      cp ${settingsFile} /opt/arm/setup/arm.yaml

      # Set proper ownership and permissions
      chown -R ${cfg.user}:${cfg.group} /opt/arm
      chown -R ${cfg.user}:${cfg.group} /home/${cfg.user}
      chmod -R 775 /opt/arm
      chmod -R 775 /home/${cfg.user}
    '';
  };
}
