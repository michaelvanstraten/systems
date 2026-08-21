{
  buildMozillaMach,
  fetchFromGitHub,
  firefox-enterprise-src,
  lib,
  nss_latest,
  writeText,
  distributionINI ? {
    "Global" = {
      id = "enterprise-local";
      version = "1.0";
      about = "Mozilla Firefox Enterprise Local Build";
    };
    "Preferences" = {
      "enterprise.console.address" = "https://stage.fx-enterprise.nonprod.webservices.mozgcp.net";
    };
  },
}:

let
  nss = nss_latest.overrideAttrs (previousAttrs: rec {
    version = "3.130";
    src = fetchFromGitHub {
      owner = "mozilla";
      repo = "nss";
      rev = "NSS_${lib.replaceStrings [ "." ] [ "_" ] version}_RTM";
      hash = "sha256-+VONkBLHqJzIufh7VCvZfGUJflOAzBemhS3z3aB8cqY=";
    };

    postPatch = previousAttrs.postPatch + ''
      substituteInPlace build.sh \
        --replace-fail '"$obj_dir/lib/pkgconfig/nspr.pc" 2>/dev/null)' \
                       '"$obj_dir/lib/pkgconfig/nspr.pc" 2>/dev/null || true)'
    '';
  });

  version = lib.trim (builtins.readFile "${firefox-enterprise-src}/browser/config/version.txt");
  toINI = lib.generators.toINI { };
  distributionINIFile = writeText "distribution.ini" (toINI distributionINI);
in
(
  (buildMozillaMach {
    pname = "firefox-enterprise";
    inherit version;

    applicationName = "Firefox Enterprise";

    src = firefox-enterprise-src;

    extraConfigureFlags = [
      "--enable-enterprise"
    ];

    extraPatches = [
      ./patches/nsAppRunner-IsLaunchingBrowserDevtools-without-updater.patch
    ];

    meta = {
      description = "Managed, open-source browsing at scale";
      maxSilent = 14400;
      mainProgram = "firefox";
    };
  }).override
    {
      nss_latest = nss;
      enableOfficialBranding = false;
      enablePGO = false;
      enableLTO = false;
      enableCrashReporter = false;
      enableDebugSymbols = false;
    }
).overrideAttrs
  (previousAttrs: {
    configureFlags = lib.filter (
      flag:
      !(lib.elem flag [
        "--enable-ffmpeg"
        "--disable-ffmpeg"
      ])
    ) previousAttrs.configureFlags;

    postInstall = previousAttrs.postInstall + ''
      install -Dvm644 "${distributionINIFile}" "$resourceDir/distribution/distribution.ini"
    '';
  })
