{ inputs, pkgs, ... }:
{
  imports = [
    ./../michael/tmux
    ./../michael/vscode.nix
    ./../michael/starship.nix
    ./../michael/poetry.nix
    ./../michael/lazygit.nix
    ./../michael/git.nix
    ./../michael/alacritty.nix
    ./../michael/sesh.nix
    ./../michael/shells
  ];

  xdg.enable = true;

  home.packages = with pkgs; [
    wget
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
    nil
    stylua
    lua-language-server
    podman
    podman-compose
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "mvanstraten@mozilla.com";
  };

  programs.eza.enable = true;

  programs.bat.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd cd" ];

  programs.thefuck.enable = true;

  programs.jq.enable = true;

  programs.sesh.enable = true;
}
