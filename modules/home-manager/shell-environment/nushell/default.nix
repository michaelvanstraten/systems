{
  programs.nushell.enable = true;
  programs.nushell.envFile.source = ./env.nu;
  programs.nushell.shellAliases = {
    c = "clear";
    l = "ls";
    la = "ls -a";
    nv = "nvim";
    lg = "lazygit";
  };

  # Command argument completion
  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;
}
