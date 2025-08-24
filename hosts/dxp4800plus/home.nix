{ self, ... }:
_: {
  home.stateVersion = "25.05";

  imports = [
    self.homeModules.all
  ];

  programs = {
    git = {
      enable = true;
      userName = "Michael van Straten";
    };
    firefox.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
  };
}
