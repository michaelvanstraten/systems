{ self, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  system.stateVersion = 5;

  users.users.michael = {
    description = "Michael van Straten";
    home = "/Users/michael";
    name = "michael";
    shell = pkgs.nushell;
    uid = 501;
  };

  networking = {
    computerName = "Michaels MacBook Pro at Mozilla";
    hostName = "michaels-mbp-mozilla";
  };

  environment.systemPackages = [
    pkgs.utm
  ];

  services.redis.enable = true;

  launchd.user.agents.redis = {
    command = lib.mkForce (
      pkgs.writeScript "redis-start" ''
          #! ${pkgs.stdenv.shell}

        # See: https://github.com/LnL7/nix-darwin/issues/659#issuecomment-1813204545
        if [ ! -d "/var/lib/redis/" ]; then
          echo "creating Redis data directory..."
          sudo mkdir -m 755 -p /var/lib/redis/
        fi

        ${config.services.redis.package}/bin/redis-server /etc/redis.conf
      ''
    );
  };

  imports = [
    self.darwinModules."applications/karabiner-elements"
    self.darwinModules."applications/yabai"
    self.darwinModules.applications
    self.darwinModules.common
    self.sharedModules.nix
  ];
}
