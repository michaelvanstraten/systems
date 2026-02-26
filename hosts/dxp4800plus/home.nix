{ self, ... }:
_: {
  home.stateVersion = "25.05";

  imports = [
    self.homeModules.all
  ];

  programs = {
    git.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    bash.enable = true;
    starship.enable = true;
  };
}
