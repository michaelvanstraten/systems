{ self, home-manager, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  primaryUser = "michael";
in
{
  imports = [
    home-manager.darwinModules.home-manager
    self.darwinModules.all
    self.sharedModules.all
    ./redis.nix
  ];

  environment.systemPackages = [
    pkgs.utm
  ];

  home-manager = {
    useUserPackages = true;
    users.michael = self.lib.mkModule ./home.nix { };
  };

  networking = {
    computerName = "Michael’s MacBook Pro at Mozilla";
    hostName = "macbook-pro-mozilla";
  };

  programs.fish.enable = true;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  services = {
    karabiner-elements.enable = true;
  };

  system = {
    inherit primaryUser;
    stateVersion = 5;
  };

  users.users.michael = {
    description = "Michael van Straten";
    home = "/Users/${primaryUser}";
    name = primaryUser;
    shell = pkgs.fish;
    uid = 501;
  };
}
