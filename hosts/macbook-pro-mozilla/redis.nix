{
  config,
  lib,
  pkgs,
  ...
}:
{
  launchd.user.agents.redis = {
    command = lib.mkForce (
      pkgs.writeScript "redis-start"
        # bash
        ''
          #! ${pkgs.stdenv.shell}

          REDIS_DIR="/var/lib/redis"
          CURRENT_USER="$(whoami)"

          # See: https://github.com/LnL7/nix-darwin/issues/659#issuecomment-1813204545
          if [ ! -d "$REDIS_DIR" ]; then
            echo "Creating Redis data directory..."
            sudo mkdir -m 755 -p "$REDIS_DIR"
            sudo chown "$CURRENT_USER" "$REDIS_DIR"
          else
            OWNER="$(stat -f %Su "$REDIS_DIR")"
            if [ "$OWNER" != "$CURRENT_USER" ]; then
              echo "Changing owner of $REDIS_DIR to $CURRENT_USER..."
              sudo chown "$CURRENT_USER" "$REDIS_DIR"
            fi
          fi

          ${config.services.redis.package}/bin/redis-server /etc/redis.conf
        ''
    );
  };

  services.redis.enable = true;
}
