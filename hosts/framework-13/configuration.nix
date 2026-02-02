{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework-13";

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalization properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Enable the openssh server
  services.openssh.enable = true;

  services.fprintd.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  services.fwupd.enable = true;

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  programs.firefox.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk3
    alsa-lib
  ];

  environment.systemPackages = with pkgs; [
    neovim
    git
    ghostty
    thunderbird
    (rustup.overrideAttrs { doCheck = false; })
    zed-editor
    python3
  ];

  # Exclude Core Apps From Being Installed.
  environment.gnome.excludePackages = [
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
    pkgs.xterm
  ];

  system.stateVersion = "25.11";
}
