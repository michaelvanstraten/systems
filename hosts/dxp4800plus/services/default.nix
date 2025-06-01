{
  self,
  ...
}:
_: {
  imports = [
    (self.lib.mkModule ./proxmox.nix { })
  ];
}
