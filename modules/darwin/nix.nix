{ lib, ... }:
{
  nix = {
    settings = {
      sandbox = "relaxed";
      extra-sandbox-paths = [
        "/nix/store"
      ];
    };

    linux-builder = {
      enable = lib.mkDefault true;
      ephemeral = true; # This fixed some issues with the builder for me
    };
  };
}
