{ self, ... }:
{
  imports = [
    (self.lib.mkModule ./buildkit { })
  ];
}
