{ self, home-manager, ... }:
{ config, pkgs, ... }:
let
  primaryUser = "michaelvanstraten";
in

{
  imports = [
    home-manager.darwinModules.home-manager
    self.darwinModules.all
    self.sharedModules.all
    (self.lib.mkModule ./secrets { })
  ];

  environment.systemPackages = [
    pkgs.alacritty
    pkgs.utm
    pkgs.grandperspective
    pkgs.python3
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
    karabiner-elements.enable = true;
    yabai.enable = true;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    inherit primaryUser;
    stateVersion = 4;
  };

  users.users.${primaryUser} = {
    description = "Michael van Straten";
    home = "/Users/${primaryUser}";
    name = primaryUser;
    shell = pkgs.fish;
    uid = 501;
  };
}
