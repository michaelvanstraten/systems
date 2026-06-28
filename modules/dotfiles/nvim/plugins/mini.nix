{ lib, ... }:
let
  inherit (lib.nixvim.utils) mkRaw;

  mkBracketPair = l: r: {
    input = [
      "%b${l}${r}"
      "^.%s*().-()%s*.$"
    ];
    output = {
      left = l;
      right = r;
    };
  };
in
{
  plugins.mini = {
    enable = true;
    modules = {
      ai = {
        custom_textobjects."$" = mkRaw ''
          require("mini.ai").gen_spec.pair("$", "$", { type = "greedy" })
        '';
      };
      pairs = {
        mappings = {
          "(" = {
            action = "open";
            pair = "()";
            neigh_pattern = "[^\\][^)]";
          };
          "[" = {
            action = "open";
            pair = "[]";
            neigh_pattern = "[^\\][^%]]";
          };
          "{" = {
            action = "open";
            pair = "{}";
            neigh_pattern = "[^\\][^}]";
          };
        };
      };

      surround.custom_surroundings = {
        "(" = mkBracketPair "(" ")";
        "[" = mkBracketPair "[" "]";
        "{" = mkBracketPair "{" "}";
        "<" = mkBracketPair "<" ">";
      };
    };
  };

  autoCmd = [
    {
      event = "FileType";
      pattern = [
        "tex"
        "typst"
      ];
      callback = mkRaw ''
        function()
          MiniPairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
        end
      '';
    }
    {
      event = "FileType";
      pattern = "rust";
      callback = mkRaw ''
        function()
          vim.keymap.set("i", "'", "'", { buffer = true, noremap = true })
        end
      '';
    }
  ];
}
