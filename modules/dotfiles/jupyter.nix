{ config, lib, ... }:
{
  options.programs.jupyterlab.enable = lib.mkEnableOption "JupyterLab user settings";

  config = lib.mkIf config.programs.jupyterlab.enable {
    home.file.".jupyter/lab/user-settings/@axlair/jupyterlab_vim/plugin.jupyterlab-settings".text =
      builtins.toJSON
        {
          extraKeybindings =
            [
              "jk"
              "kj"
            ]
            |> map (command: {
              inherit command;
              keys = "<Esc>";
              context = "insert";
            });
        };
  };
}
