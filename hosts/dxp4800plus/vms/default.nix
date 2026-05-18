{ self, microvm, ... }:
{
  imports = [
    microvm.nixosModules.host
    (self.lib.mkModule ./buildkit { })
    (self.lib.mkModule ./github-runners { })
  ];

  systemd.network.networks."40-microvm" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "br-vms";
  };
}
