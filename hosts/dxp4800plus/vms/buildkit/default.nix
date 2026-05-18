{ self, ... }:
{
  microvm.vms.buildkit.config = self.lib.mkModule ./configuration.nix { };
  microvm.autostart = [ "buildkit" ];
}
