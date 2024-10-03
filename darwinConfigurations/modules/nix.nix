{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    channel.enable = false;
    distributedBuilds = true;
    linux-builder = {
      enable = true;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
      trusted-users = [ "@admin" ];
    };
    extraOptions = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  services.nix-daemon.enable = true;

  nixpkgs = {
    source = inputs.nixpkgs;
  };

}
