{
  config,
  lib,
  pkgs,
  make-disk-image,
  ...
}:
{
  system.build.disk-image = make-disk-image {
    inherit config lib pkgs;
    partitionTableType = "efi";
    format = "raw";
  };
}
