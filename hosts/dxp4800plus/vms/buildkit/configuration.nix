{ self, ... }:
{
  config,
  vmSecretsHostPath,
  ...
}:
let
  vmIp = "10.101.0.2";
  tcpPort = "1234";
  vmSecretsGuestPath = "/run/host-secrets";
in
{
  imports = [ self.nixosModules.buildkitd ];

  services.buildkitd = {
    enable = true;
    settings = {
      root = "/var/lib/buildkit";

      grpc.address = [
        "tcp://0.0.0.0:${tcpPort}"
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

  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 4096;
    vsock.cid = 9;
    interfaces = [
      {
        type = "tap";
        id = "vm-buildkit";
        mac = "02:00:00:00:00:09";
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
        imageType = "qcow2";
        mountPoint = config.services.buildkitd.settings.root;
        size = 64000;
      }
    ];
  };

  services.newt = {
    enable = true;
    settings.endpoint = "https://pangolin.vanstraten.cloud";
    environmentFile = "${vmSecretsGuestPath}/newt/env";
    blueprint = {
      private-resources = {
        buildkit-linux-amd64 = {
          name = "BuildKit linux/amd64";
          mode = "host";
          destination = "localhost";
          alias = "linux-amd64.buildkit.vanstraten.cloud";
          tcp-ports = tcpPort;
          disable-icmp = true;
          machines = [
            "affectionate-russian-desman"
            "thorough-seven-banded-armadillo"
          ];
        };
      };
    };
  };

  networking.useNetworkd = true;

  systemd.network.networks."10-lan" = {
    matchConfig.MACAddress = "02:00:00:00:00:09";
    networkConfig = {
      Address = "${vmIp}/24";
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
