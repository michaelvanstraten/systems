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
      environment.shells =
        config.users.users
        |> lib.mapAttrsToList (_: user: user.shell)
        |> builtins.filter (shell: !builtins.isNull shell);

      users.knownUsers =
        config.users.users
        |> lib.attrsets.filterAttrs (_: user: user.shell != null)
        |> lib.mapAttrsToList (_: user: user.name);

      security.pam.services.sudo_local.enable = true;
      security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.services.sudo_local.reattach = true;

      programs.fish.enable = true;

      environment.enableEssentialPackages = lib.mkDefault true;
    }
    (lib.mkIf config.environment.enableEssentialPackages {
      environment.systemPackages = [
        pkgs.darwin.trash
      ];
    })
    {
      nix.settings = {
        sandbox = true;
        extra-sandbox-paths = [
          "/nix/store"
        ];
      };
    }
  ];
}
