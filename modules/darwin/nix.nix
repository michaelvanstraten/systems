{ lib, ... }:
{
  nix = {
    settings = {
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
