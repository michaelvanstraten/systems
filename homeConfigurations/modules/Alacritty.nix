{ inputs, pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerdfonts ];
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${inputs.cyberdream-theme}/extras/alacritty/cyberdream.toml" ];
      font = {
        size = 14;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium Italic";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Heavy";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Heavy Italic";
        };
      };
      selection = {
        save_to_clipboard = true;
      };
      window = {
        decorations = "Transparent";
        dynamic_padding = true;
        opacity = 0.87;
        blur = true;

        dimensions = {
          columns = 128;
          lines = 38;
        };

        padding = {
          x = 18;
          y = 16;
        };
      };
      keyboard.bindings = [
        {
          key = "A";
          mods = "Command";
          chars = "\\u0001";
        }
        {
          key = "J";
          mods = "Command";
          chars = "\\u0001T";
        }
      ];
    };
  };
}
