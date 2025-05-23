{ cyberdream-theme, ... }:
{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [ "${cyberdream-theme}/extras/alacritty/cyberdream.toml" ];
      font = {
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
          key = "s";
          mods = "Command";
          chars = "\\u0001s";
        }
      ];
    };
  };
}
