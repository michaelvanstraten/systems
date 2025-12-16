{ self, ... }:
_: {
  home.stateVersion = "25.11";

  imports = [
    self.homeModules.all
  ];

  programs = {
    git = {
      enable = true;
      settings = {
        user.name = "Michael van Straten";
        user.email = "mvanstraten@mozilla.com";
      };
    };
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    bash.enable = true;
    starship.enable = true;
    starship.enableBashIntegration = true;
    mach.enable = true;
  };
}
