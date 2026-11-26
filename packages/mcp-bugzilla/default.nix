{
  fetchFromGitHub,
  lib,
  python3,
}:

let
  tools = import ./tools.nix;

  # nixpkgs still ships fastmcp 3, which is marked broken because it does not
  # support mcp 2. Build the fastmcp 4 release that mcp-bugzilla pins instead.
  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      fastmcp = prev.fastmcp.overridePythonAttrs (_: rec {
        version = "4.1.4";

        src = fetchFromGitHub {
          owner = "PrefectHQ";
          repo = "fastmcp";
          tag = "v${version}";
          hash = "sha256-0dYllqo4mrKmJoX7QMobAOMXQK7qr2wcvxEqQvwAbbM=";
        };

        patches = [ ];
        doCheck = false;
      });

      # Inherits version and src from fastmcp.
      fastmcp-slim = prev.fastmcp-slim.overridePythonAttrs (old: {
        patches = [ ];
        dependencies = old.dependencies ++ [ final.mcp-types ];
        meta = old.meta // {
          broken = false;
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mcp-bugzilla";
  version = "0.22.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "mcp-bugzilla";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qk4WdPkEXK0p3mppEkr/390dc8pNojwbP6PhtiLC19M=";
  };

  build-system = [ python.pkgs.uv-build ];

  dependencies = [
    python.pkgs.fastmcp
    python.pkgs.httpx-retries
  ];

  nativeCheckInputs = [
    python.pkgs.pytest-asyncio
    python.pkgs.pytestCheckHook
    python.pkgs.respx
  ];

  pythonImportsCheck = [ "mcp_bugzilla" ];

  postCheck = ''
    python ${./check-tools.py} ${lib.escapeShellArgs tools.read}
  '';

  passthru = { inherit tools; };

  meta = {
    description = "Model Context Protocol (MCP) server for Bugzilla";
    homepage = "https://github.com/openSUSE/mcp-bugzilla";
    changelog = "https://github.com/openSUSE/mcp-bugzilla/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "mcp-bugzilla";
  };
})
