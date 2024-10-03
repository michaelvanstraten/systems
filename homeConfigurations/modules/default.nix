{ ... }:
{
  darwin = import ./darwin;
  Karabiner-Elements = import ./Karabiner-Elements;
  mozconfig = import ./mozconfig;
  nvim = import ./nvim;
  sdkh = import ./sdkh;
  tmux = import ./tmux;
  yabai = import ./yabai;
  Alacritty = import ./Alacritty.nix;
  Firefox = import ./Firefox.nix;
  git = import ./git.nix;
  Lazygit = import ./Lazygit.nix;
  Poetry = import ./Poetry.nix;
  sesh = import ./sesh.nix;
  shells = import ./shells.nix;
  starship = import ./starship.nix;
  VSCodium = import ./VSCodium.nix;
}
