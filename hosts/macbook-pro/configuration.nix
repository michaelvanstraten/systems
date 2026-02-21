{ self, home-manager, ... }:
{ config, pkgs, ... }:
let
  primaryUser = "michael";
in

{
  imports = [
    home-manager.darwinModules.home-manager
    self.darwinModules.all
    self.sharedModules.all
    (self.lib.mkModule ./secrets { })
    (self.lib.mkModule ./homebrew.nix { inherit primaryUser; })
  ];

  environment.systemPackages = [
    pkgs.utm
    pkgs.grandperspective
    pkgs.monitorcontrol
    pkgs.python3
    pkgs.zed-editor
    pkgs.firefox
    pkgs.bitwarden-desktop
    pkgs.anki
    pkgs.rustup
  ];

  home-manager = {
    useUserPackages = true;
    users.${primaryUser} = self.lib.mkModule ./home.nix { };
  };

  networking = {
    computerName = "Michael’s MacBook Pro";
    hostName = "macbook-pro";
  };

  nix.autoDiscoverBuildMachines = {
    enable = true;
    sshKey = config.sops.secrets.nixremote-ssh-key.path;
  };

  programs.fish.enable = true;

  services = {
    karabiner-elements.enable = false;
    yabai.enable = false;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    inherit primaryUser;
    stateVersion = 6;
  };

  users.users.${primaryUser} = {
    description = "Michael van Straten";
    home = "/Users/${primaryUser}";
    name = primaryUser;
    shell = pkgs.fish;
    uid = 501;
  };
}
