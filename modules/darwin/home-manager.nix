{ specialArgs, ... }:
{
  home-manager = {
    backupFileExtension = "before-home-manager";
    extraSpecialArgs = specialArgs;
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
}
