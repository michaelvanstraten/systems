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
    (self.lib.mkModule ./secrets.nix { })
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

  services.github-runners = {
    "enterprise-helm" = {
      enable = true;
      url = "https://github.com/mozilla/enterprise-helm";
      tokenFile = config.sops.secrets."github_runners/enterprise_helm/token".path;
      name = config.networking.hostName;
    };
  };

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
