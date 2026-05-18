{ self, microvm, ... }:
{
  imports = [
    microvm.nixosModules.host
    (self.lib.mkModule ./buildkit { })
  ];

  systemd.network.networks."40-microvm" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "br-vms";
  };
}
