{ self, ... }:
{
  homeModules = self.lib.mkModules ./modules;
}
