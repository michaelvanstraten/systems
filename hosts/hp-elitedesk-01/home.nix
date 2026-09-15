{ self, ... }:
_: {
  home.stateVersion = "25.05";

  imports = [
    self.homeModules.all
  ];

  programs = {
    bash.enable = true;
    starship.enable = true;
  };
}
