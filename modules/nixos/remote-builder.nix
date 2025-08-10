{ config, lib, ... }:
let
  # Define the configuration options for the module
  cfg = config.nix.remoteBuilder;
in
{
  options.nix.remoteBuilder = {
    enable = lib.mkEnableOption "Enable remote builder functionality";

    supportedFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "kvm"
        "big-parallel"
      ];
      description = ''
        A list of features supported by this builder. The builder will
        be ignored for derivations that require features not in this
        list.
      '';
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of SSH public keys authorized to access the remote builder.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "The remote builder system assumes you are using Tailscale as an overlay network";
      }
    ];

    # Enable the remote builder by default if the module is enabled
    nix.settings.trusted-users = [ "nixremote" ];

    # Define the nixremote user
    users.users."nixremote" = {
      isNormalUser = true;
      hashedPassword = "!";
      group = "nixremote";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    # Define the nixremote group
    users.groups."nixremote" = { };
  };
}
