{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.latest.overrideAttrs {
      doCheck = false;
    };
    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "dynamic-derivations"
        "fetch-closure"
        "flakes"
        "git-hashing"
        "nix-command"
        "pipe-operators"
        "recursive-nix"
        "verified-fetches"
      ];
      trusted-users = [
        "@admin"
        "@wheel"
      ];
    };
  };
}
