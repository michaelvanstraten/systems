{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = [
      pkgs.unnaturalscrollwheels
    ];

    variables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
    };

    shells =
      config.users.users
      |> lib.mapAttrsToList (_: user: user.shell)
      |> builtins.filter (shell: !builtins.isNull shell);
  };

  users.knownUsers =
    config.users.users
    |> lib.attrsets.filterAttrs (_: user: user.shell != null)
    |> lib.mapAttrsToList (_: user: user.name);

  system.startup.chime = false;
}
