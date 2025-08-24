{ pkgs, ... }:
{
  services = {
    desktopManager.gnome.enable = true;

    xserver = {
      xkb.layout = "de";
    };

    displayManager = {
      gdm = {
        enable = true;
        autoSuspend = false;
      };
    };

    rustdesk-server = {
      enable = true;
      openFirewall = true;
      signal.relayHosts = [ "example.com" ];
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.vpl-gpu-rt
    ];
  };
}
