{
  buildPythonApplication,
  python,
  hatchling,
  fetchFromGitHub,
  pyproject-nix,
  applyPatches,
  callPackage,
  ...
}:
let
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "automatic-ripping-machine";
    repo = "automatic-ripping-machine";
    rev = version;
    hash = "sha256-fwiJHAOqKKEyayMQ83C0f/HobgeHzQMT1zREgJngRCA=";
    fetchSubmodules = true;
  };

  patched-src = applyPatches {
    inherit src;

    patches = [
      ./remove-bad-deps.patch
    ];
  };

  # Load/parse arm requirements.txt
  arm-project = pyproject-nix.lib.project.loadRequirementsTxt {
    projectRoot = "${patched-src}";
    requirements = "${patched-src}/requirements.txt";
  };

  pydvdid = callPackage ./pydvdid.nix { };
in
buildPythonApplication (
  (
    arm-project.renderers.buildPythonPackage {
      inherit python;
      pythonPackages = python.pkgs // {
        inherit pydvdid;
      };
    }
    // rec {
      pname = "automatic-ripping-machine";
      inherit version;
      src = patched-src;

      patches = [
        ./add-proper-main.patch
      ];

      build-system = [
        hatchling
      ];

      preBuild = ''
        cat > pyproject.toml << EOF
        [build-system]
        requires = ["hatchling"]
        build-backend = "hatchling.build"

        [project]
        name = "${pname}"
        version = "${version}"

        [project.scripts]
        arm = "arm.runui:main"

        [tool.hatch.build]
        include = ["arm/*"]
        EOF
      '';

      postInstall = ''
        # Create necessary directories for additional files
        mkdir -p $out/share/arm/setup
        mkdir -p $out/share/arm/scripts/thickclient

        # Copy needed setup files (excluding the ones we don't need)
        for file in $(find $src/setup -type f -not -name "51-automedia.rules" -not -name "armui.service"); do
          cp -v "$file" $out/share/arm/setup/
        done

        # Copy only the required scripts
        cp -v $src/scripts/thickclient/arm_wrapper.sh $out/share/arm/scripts/thickclient/
        cp -v $src/scripts/update_key.sh $out/share/arm/scripts/

        # Ensure ARM scripts are executable
        chmod +x $out/share/arm/scripts/thickclient/arm_wrapper.sh
        chmod +x $out/share/arm/scripts/update_key.sh
      '';
    }
  )
)
