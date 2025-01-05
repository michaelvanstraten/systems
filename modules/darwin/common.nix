{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    environment.enableEssentialPackages = lib.mkEnableOption "Enable essential packages";
  };

  config = lib.mkMerge [
    {
      environment.shells = lib.mapAttrsToList (_: user: user.shell) config.users.users;

      users.knownUsers =
        config.users.users
        |> lib.attrsets.filterAttrs (_: user: user.shell != null)
        |> lib.mapAttrsToList (_: user: user.name);

      security.pam.enableSudoTouchIdAuth = true;

      programs.fish.enable = true;

      environment.enableEssentialPackages = lib.mkDefault true;
    }
    (lib.mkIf config.environment.enableEssentialPackages {
      environment.systemPackages = [
        pkgs.darwin.trash
      ];
    })
  ];
}
