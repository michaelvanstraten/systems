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
      maxJobs = 2;
      config = {
        virtualisation = {
          cores = 8;
          darwin-builder = {
            memorySize = 12 * 1024;
            diskSize = 60 * 1024;
          };
        };
      };
    };
  };
}
