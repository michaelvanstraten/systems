{ self, ... }:
{ ... }:
{
  imports = [
    self.homeModules.all
  ];

  home.stateVersion = "26.05";

  programs = {
    bash.enable = true;
    starship.enable = true;
  };
}
