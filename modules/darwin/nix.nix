{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    distributedBuilds = true;
    linux-builder.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@admin" ];
    };
  };

  services.nix-daemon.enable = true;
}
