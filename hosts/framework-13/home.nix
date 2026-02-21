{ self, ... }:
{ config, ... }:
{
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.cargo/bin/" ];

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
      signing.key = "${config.home.homeDirectory}/.ssh/id_ecdsa.pub";
      signing.signByDefault = true;
    };
    lazygit.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    bash.enable = true;
    starship.enable = true;
    starship.enableBashIntegration = true;
    mach.enable = true;
    moz-phab.enable = true;
  };
}
