{ cyberdream-theme, ... }:
{ ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "cyberdream";
    };
    themes = {
      cyberdream = builtins.fromTOML (
        builtins.readFile "${cyberdream-theme}/extras/helix/cyberdream.toml"
      );
    };
  };
}
