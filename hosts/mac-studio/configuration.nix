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
  ];

  environment.systemPackages = [
    pkgs.firefox
    pkgs.alacritty
  ];

  home-manager = {
    useUserPackages = true;
    users.michael = self.lib.mkModule ./home.nix { };
  };

  networking = {
    computerName = "Firefox Enterprise Mac Studio (M2 Max)";
    hostName = "fxe-mac-studio-01";
  };

  services.tailscale.enable = true;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    inherit primaryUser;
    stateVersion = 5;
  };

  power.sleep.computer = "never";

  users.users.michael = {
    description = "Michael van Straten";
    home = "/Users/${primaryUser}";
    name = primaryUser;
    shell = pkgs.bash;
    uid = 501;
  };
}
