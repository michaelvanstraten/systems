{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        scrollPastBottom = false;
        expandFocusedSidePanel = true;
        showCommandLog = true;
        skipRewordInEditorWarning = true;
      };

      git = {
        paging.useConfig = false;
        autoFetch = false;
        autoRefresh = true;
        fetchAll = true;
        parseEmoji = true;
      };

      os = {
        editPreset = "nvim";
      };

      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
    };
  };
}
