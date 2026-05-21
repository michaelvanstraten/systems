{ self, ... }:
{
  lib,
  config,
  vmSecretsHostPath,
  ...
}:
let
  vmSecretsGuestPath = "/run/host-secrets";
in
{
  imports = [ self.nixosModules.buildkitd ];

  services.buildkitd = {
    enable = true;
    settings = {
      root = "/var/lib/buildkit";

      grpc.address = [
        "tcp://0.0.0.0:1234"
      ];

      cdi.disabled = true;

      worker = {
        oci.enabled = true;
        oci.snapshotter = "overlayfs";
        containerd.enabled = false;
      };

      frontend = {
        "dockerfile.v0".enabled = true;
        "gateway.v0".enabled = false;
      };
    };
  };

  services.newt = {
    enable = true;
    settings.endpoint = "https://pangolin.vanstraten.cloud";
    environmentFile = "${vmSecretsGuestPath}/newt/env";
    blueprint = {
      private-resources = {
        buildkit-linux-arm64 = {
          name = "BuildKit linux/arm64";
          mode = "host";
          destination = "localhost";
          alias = "linux-arm64.buildkit.vanstraten.cloud";
          tcp-ports = "1234";
          disable-icmp = true;
          machines = [
            "affectionate-russian-desman"
            "thorough-seven-banded-armadillo"
          ];
        };
      };
    };
  };

  microvm = {
    vcpu = 4;
    mem = 4096;
    interfaces = [
      {
        type = "user";
        id = "buildkit-net";
        mac = "dc:3b:a1:59:fb:a5";
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
        image = "buildkit-state.img";
        mountPoint = config.services.buildkitd.settings.root;
        size = 64000;
        fsType = "ext4";
      }
    ];
  };

  # Debugging
  # services.getty.autologinUser = "root";
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "yes";
  #     PermitEmptyPasswords = "yes";
  #   };
  # };
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # security.pam.services.sshd.allowNullPassword = true;
  # users.users.root.password = "";

  system.stateVersion = lib.trivial.release;
}
