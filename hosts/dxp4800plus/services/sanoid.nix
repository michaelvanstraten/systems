{
  services.sanoid = {
    enable = true;

    templates = {
      default = {
        hourly = 0;
        daily = 0;
        weekly = 0;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
    };

    datasets = {
      "zroot" = {
        daily = 7;
        weekly = 4;
        monthly = 3;
      };

      "tank/appdata" = {
        recursive = true;
        processChildrenOnly = true;
        daily = 7;
        weekly = 4;
        monthly = 3;
      };
      "tank/media" = {
        weekly = 4;
        monthly = 1;
      };
      # Timemachine backups
      "tank/timemachine" = {
        recursive = true;
        processChildrenOnly = true;
        monthly = 3;
      };
      # SMB home directories
      "tank/homes" = {
        recursive = true;
        processChildrenOnly = true;
        daily = 7;
        weekly = 4;
        monthly = 3;
      };
    };
  };
}
