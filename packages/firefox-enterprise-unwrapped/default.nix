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
    version = "3.134";
    src = fetchFromGitHub {
      owner = "mozilla";
      repo = "nss";
      rev = "NSS_${lib.replaceStrings [ "." ] [ "_" ] version}_RTM";
      hash = "sha256-xTAKUzXyPcuLiDZxIixd0/WOaH785MAS6CaypZonM08=";
    };
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

    preBuild = previousAttrs.preBuild + ''
      date -u -d @${toString (firefox-enterprise-src.lastModified or 0)} +%Y%m%d%H%M%S > buildid.txt
      printf '%s\n%s\n' '${firefox-enterprise-src.rev or ""}' \
        'https://github.com/mozilla/enterprise-firefox' > source-repo.txt
    '';

    postInstall = previousAttrs.postInstall + ''
      install -Dvm644 "${distributionINIFile}" "$resourceDir/distribution/distribution.ini"
    '';
  })
