{ pkgs, ... }:
{
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  nixpkgs.config.allowUnfree = true;

  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver
  #     intel-compute-runtime
  #     vpl-gpu-rt
  #     intel-media-sdk
  #     intel-ocl
  #   ];
  # };
  #
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;

  services.samba = {
    enable = true;
    settings = {
      global = {
        "hosts allow" = "100.64.0.0/10 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      media = {
        path = "/tank/media";
        browseable = true;
        "guest ok" = true;
        "read only" = "no";
        "writeable" = "yes";
        "force user" = "nobody";
        "force group" = "nogroup";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
    openFirewall = true;
  };

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
