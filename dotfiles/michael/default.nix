{ inputs, pkgs, ... }:
{
  imports = [
    ./tmux
    ./vscode.nix
    ./starship.nix
    ./poetry.nix
    ./lazygit.nix
    ./git.nix
    ./alacritty.nix
    ./sesh.nix
    ./shells
  ];

  xdg.enable = true;

  home.packages = with pkgs; [
    wget
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
    nil
    stylua
    lua-language-server
    nixfmt-rfc-style
    firefox-bin
    ltex-ls
    podman
    podman-compose
    nodejs_22
    tree-sitter
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";

  programs.git = {
    userName = "Michael van Straten";
    userEmail = "michael@vanstraten.de";
  };

  programs.eza.enable = true;

  programs.bat.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd cd" ];

  programs.thefuck.enable = true;

  programs.jq.enable = true;

  programs.sesh.enable = true;
}
