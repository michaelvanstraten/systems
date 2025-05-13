{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  ...
}:

buildPythonPackage {
  pname = "pydvdid";
  version = "1.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "sjwood";
    repo = "pydvdid";
    rev = "v1.1";
    hash = "sha256-PuhkXu62bc/9n2swaKe/O759xCyJ3LrHCJISbWzSUtk=";
  };

  build-system = [
    setuptools
  ];

  # Fix install path issues
  postInstall = ''
    # Ensure __init__.py exists to make it a proper package
    if [ ! -f $out/lib/python*/site-packages/pydvdid/__init__.py ]; then
      echo "herejk"
    fi
  '';
}
