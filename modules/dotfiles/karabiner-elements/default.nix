{ config, lib, ... }:
let
  cfg = config.programs.karabiner-elements;
in
{
  options.programs.karabiner-elements = {
    enable = lib.mkEnableOption "install Karabiner-Elements configuration and assets";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/karabiner/assets".source = ./assets;
    home.file.".config/karabiner/karabiner.json".source = ./karabiner.json;
  };
}
