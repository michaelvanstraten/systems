{
  config,
  lib,
  ...
}:
{
  options.internal = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      example = "macbook-pro";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "vanstraten.cloud";
    };

    fullyQualifiedHostName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${config.internal.hostName}.${config.internal.domain}";
      defaultText = lib.literalExpression ''"${config.internal.hostName}.${config.internal.domain}"'';
    };

    sshAccess.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.internal.sshAccess.enable {
    assertions = [
      {
        assertion = config.services.newt.enable;
        message = "`internal.sshAccess.enable` requires newt to be enabled";
      }
    ];

    services.newt.blueprint.private-resources."ssh-${config.internal.hostName}" = {
      name = "SSH (${config.internal.hostName})";
      alias = config.internal.fullyQualifiedHostName;
      mode = "ssh";
      destination = "127.0.0.1";
      tcp-ports = "22";
    };
  };
}
