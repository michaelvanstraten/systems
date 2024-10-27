{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    distributedBuilds = true;
    linux-builder.enable = false;
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      trusted-users = [ "@admin" ];
    };
  };

  services.nix-daemon.enable = true;
}
