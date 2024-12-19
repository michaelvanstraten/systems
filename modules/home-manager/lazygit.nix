{
  home.shellAliases  = {
    lg = "lazygit";
  };

  programs.lazygit = {
    enable = true;
    settings = {
      disableStartupPopups = true;
      git = {
        paging.useConfig = false;
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
}
