{ pkgs, ... }:
{
  imports = [
    ../modules/git.nix
    ../modules/nvim
    ../modules/Lazygit.nix
    ../modules/starship.nix
    ../modules/sesh.nix
    ../modules/shells.nix
    ../modules/tmux
  ];

  xdg.enable = true;

  home = {
    packages = [ pkgs.wget ];
    sessionVariables = {
      EDITOR = "nvim";
    };
    stateVersion = "24.05";
    shellAliases = {
      ls = "eza";
    };
  };

  programs = {
    eza.enable = true;

    sesh.enable = true;

    thefuck.enable = true;

    zoxide.enable = true;
    zoxide.options = [ "--cmd cd" ];
  };
}
