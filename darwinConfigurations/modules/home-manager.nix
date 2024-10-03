{ inputs, ... }:
{
  home-manager = {
    backupFileExtension = "before-home-manager";
    extraSpecialArgs = {
      inherit inputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
}
