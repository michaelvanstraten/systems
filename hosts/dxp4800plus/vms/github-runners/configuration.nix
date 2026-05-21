{ self, ... }:
{
  lib,
  runners,
  vmSecretsHostPath,
  vmSecretsGuestPath,
  ...
}:
{
  imports = [ self.nixosModules.olm ];

  services.github-runners = lib.listToAttrs (
    map (
      r:
      lib.nameValuePair r.registrationName {
        enable = true;
        replace = true;
        url = "https://github.com/mozilla/enterprise-console-backend";
        inherit (r) tokenFile;
        name = r.registrationName;
      }
    ) runners
  );

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
        mac = "02:00:00:00:00:0a";
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
        mountPoint = "/var/lib/github-runner";
        size = 64000;
      }
    ];
  };

  networking.useNetworkd = true;

  systemd.network.networks."10-lan" = {
    matchConfig.MACAddress = "02:00:00:00:00:0a";
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

  system.stateVersion = "25.11";
}
