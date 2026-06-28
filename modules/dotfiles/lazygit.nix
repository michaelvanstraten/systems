{ config, lib, ... }:
{
  config = lib.mkIf config.programs.lazygit.enable {
    home.shellAliases = {
      lg = "lazygit";
    };

    programs.lazygit = {
      settings = {
        disableStartupPopups = true;
        git = {
          pagers = [ ];
          autoFetch = false;
          autoRefresh = true;
          fetchAll = true;
          parseEmoji = true;
        };
        gui = {
          scrollPastBottom = false;
          expandFocusedSidePanel = true;
          showCommandLog = true;
          skipRewordInEditorWarning = true;
        };
        notARepository = "skip";
        promptToReturnFromSubprocess = false;
      };
    };
  };
}
