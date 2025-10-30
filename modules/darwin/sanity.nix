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
