{ self, ... }:
{ config, ... }:
{
  imports = [ self.nixosModules.buildkitd ];

  services.buildkitd = {
    enable = true;
    settings = {
      root = "/var/lib/buildkit";

      grpc.address = [
        "unix:///run/buildkit/buildkitd.sock"
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

  networking = {
    useNetworkd = true;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    firewall.allowedTCPPorts = [ 1234 ];
  };

  systemd.network.networks."10-lan" = {
    matchConfig.MACAddress = "02:00:00:00:00:09";
    networkConfig = {
      Address = "10.101.0.9/24";
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
