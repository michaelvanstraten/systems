{ self, ... }:
{ pkgs, ... }:
{
  system.stateVersion = 5;

  users.users.michael = {
    description = "Michael van Straten";
    home = "/Users/michael";
    name = "michael";
    shell = pkgs.nushell;
    uid = 501;
  };

  networking = {
    computerName = "Michaels MacBook Pro at Mozilla";
    hostName = "michaels-mbp-mozilla";
  };

  environment.systemPackages = [
    pkgs.utm
  ];

  services.redis.enable = true;

  imports = [
    self.darwinModules."applications/karabiner-elements"
    self.darwinModules."applications/yabai"
    self.darwinModules.applications
    self.darwinModules.common
    self.sharedModules.nix
  ];
}
