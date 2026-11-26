{ self, ... }: { pkgs, lib, ... }: {
  programs.opencode = {
    enableMcpIntegration = true;

    # Ask before any Bugzilla tool that is not known to be read-only. The last
    # matching rule wins.
    settings.permissions = [
      {
        action = "bugzilla-mozilla-org_*";
        resource = "*";
        effect = "ask";
      }
    ]
    ++ map (tool: {
      action = "bugzilla-mozilla-org_${tool}";
      resource = "*";
      effect = "allow";
    }) self.packages.${pkgs.stdenv.system}.mcp-bugzilla.tools.read;
  };

  programs.mcp = {
    enable = true;
    servers = {
      bugzilla-mozilla-org = {
        command = lib.getExe self.packages.${pkgs.stdenv.system}.mcp-bugzilla;
        args = [
          "--transport"
          "stdio"
          "--bugzilla-server"
          "https://bugzilla.mozilla.org/"
        ];
      };
    };
  };
}
