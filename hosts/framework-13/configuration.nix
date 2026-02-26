{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      git
      ghostty
      thunderbird
      rustup
      zed-editor
      python3
      jq
      signal-desktop
      k9s
      gh
      quickemu
      spice
      gdb
      (pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))
      kubernetes-helm
      kubectl
    ];

    gnome.excludePackages = [
      pkgs.epiphany # web browser
      pkgs.gedit # text editor
      pkgs.totem # video player
      pkgs.yelp # help viewer
      pkgs.geary # email client
      pkgs.gnome-calendar # calendar
      pkgs.gnome-contacts # contacts
      pkgs.gnome-maps # maps
      pkgs.gnome-music # music
      pkgs.gnome-photos # photos
      pkgs.gnome-tour # tour app
      pkgs.evince # document viewer
    ];
  };

  programs = {
    firefox.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        gtk3
        alsa-lib
        libx11
        libxcb
        libxcomposite
        libxrandr
        libxcursor
        libxdamage
        libxi
        libxext
        libxfixes
        libz
      ];
    };
  };

  services = {
    fprintd.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "de";
      variant = "nodeadkeys";
    };
    fwupd.enable = true;
    tailscale.enable = true;
    openssh.enable = true;
    upower.enable = true;
  };

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  virtualisation.docker.enable = true;

  networking = {
    hostName = "framework-13";
    networkmanager.enable = true;
    # networkmanager.dns = "systemd-resolved";
    networkmanager.dns = "dnsmasq";
  };
  # services.resolved.enable = true;

  security.pki.certificateFiles = [ ./mkcert/rootCA.pem ];

  powerManagement.powertop.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "Europe/Berlin";

  system.stateVersion = "25.11";
}
