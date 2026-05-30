{ self, ... }:
{
  lib,
  pkgs,
  runners,
  vmSecretsHostPath,
  vmSecretsGuestPath,
  ...
}:
let
  stateDir = "/var/lib/github-runner";
  user = "github-runner";
  group = "github-runner";
  vmMac = "02:00:00:00:00:0a";
in
{
  imports = [
    self.nixosModules.olm
  ];

  users.groups.${group} = { };

  users.users.${user} = {
    isSystemUser = true;
    inherit group;
    home = stateDir;
    createHome = true;
    extraGroups = [ "docker" ];
  };

  systemd.tmpfiles.settings."10-github-runners-shared" = {
    "${stateDir}/shared".d = {
      mode = "0750";
      inherit user group;
    };
  };

  systemd.tmpfiles.settings."10-github-runners" = lib.listToAttrs (
    map (
      r:
      lib.nameValuePair "${stateDir}/${r.registrationName}/_work" {
        d = {
          mode = "0750";
          inherit user group;
        };
      }
    ) runners
  );

  services.github-runners = lib.listToAttrs (
    map (
      r:
      lib.nameValuePair r.registrationName {
        enable = true;
        replace = true;
        inherit user group;
        workDir = "${stateDir}/${r.registrationName}/_work";
        url = "https://github.com/mozilla/enterprise-console-backend";
        inherit (r) tokenFile;
        name = r.registrationName;

        nodeRuntimes = [ "node24" ];

        extraPackages = [
          pkgs.gcc
          pkgs.pkg-config
          pkgs.toybox
          pkgs.curl
          pkgs.docker
        ];

        extraEnvironment = {
          CARGO_HOME = "${stateDir}/shared/cargo";
          CARGO_TARGET_DIR = "${stateDir}/shared/cargo/target";

          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

          LD_LIBRARY_PATH = lib.makeLibraryPath [
            pkgs.openssl
            pkgs.nss
            pkgs.nspr
            pkgs.atk
            pkgs.cups
            pkgs.dbus
            pkgs.expat
            pkgs.libdrm
            pkgs.libxkbcommon
            pkgs.mesa
            pkgs.pango
            pkgs.cairo
            pkgs.alsa-lib
            pkgs.libx11
            pkgs.libxcomposite
            pkgs.libxdamage
            pkgs.libxext
            pkgs.libxfixes
            pkgs.libxrandr
            pkgs.libxcb
            pkgs.libxrender
          ];

          PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" [
            pkgs.openssl.dev
          ];
        };

        serviceOverrides = {
          ReadWritePaths = [ "${stateDir}/shared" ];
          ProtectProc = "default";
        };
      }
    ) runners
  );

  virtualisation.docker.enable = true;

  programs.nix-ld.enable = true;

  services.olm = {
    enable = true;
    environmentFile = "${vmSecretsGuestPath}/olm/env";
    settings."override-dns" = true;
  };

  services.resolved.enable = true;
  security.polkit.enable = true;

  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 8192;
    vsock.cid = 10;
    interfaces = [
      {
        type = "tap";
        id = "vm-gh-runners";
        mac = vmMac;
        tap.vhost = true;
      }
    ];
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
      {
        source = vmSecretsHostPath;
        mountPoint = vmSecretsGuestPath;
        tag = "ro-secrets";
        proto = "virtiofs";
      }
    ];
    volumes = [
      {
        image = "github-runner-state.img";
        imageType = "qcow2";
        mountPoint = stateDir;
        size = 64000;
      }
    ];
  };

  networking.useNetworkd = true;

  systemd.network.networks."10-lan" = {
    matchConfig.MACAddress = vmMac;
    networkConfig = {
      Address = "10.101.0.3/24";
      Gateway = "10.101.0.1";
      DHCP = "no";
      LinkLocalAddressing = "no";
    };
  };

  # Debugging
  microvm.vsock.ssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PermitEmptyPasswords = "yes";
  };
  security.pam.services.sshd.allowNullPassword = true;
  users.users.root.hashedPassword = "";

  system.stateVersion = lib.trivial.release;
}
