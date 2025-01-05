{
  programs.nushell.enable = true;
  programs.nushell.envFile.source = ./env.nu;
  programs.nushell.configFile.source = ./config.nu;
  programs.nushell.shellAliases = {
    c = "clear";
    l = "ls";
    la = "ls -a";
    nv = "nvim";
    lg = "lazygit";
  };

}
