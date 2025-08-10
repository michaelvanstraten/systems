{ nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;
  inherit (lib) fileset;

  mkModule =
    modulePath: _:
    let
      module = import modulePath;
      isFlakeModule =
        module:
        builtins.isFunction module
        && (builtins.functionArgs module |> builtins.intersectAttrs inputs) != { };
    in
    if isFlakeModule module then module inputs else module;

  mkModules =
    dir:
    fileset.fileFilter (file: file.hasExt "nix") dir
    |> fileset.toList
    |> map (
      module:
      let
        moduleName =
          module
          |> toString
          |> lib.removeSuffix ".nix"
          |> lib.removePrefix (toString dir)
          |> lib.removePrefix "/";
      in
      if lib.hasSuffix "default" moduleName then
        {
          ${lib.removeSuffix "/default" moduleName} = mkModule module { };
        }
      else
        { ${moduleName} = mkModule module { }; }
    )
    |> (
      allModules:
      allModules
      ++ [
        {
          all = {
            imports = allModules |> map lib.attrValues |> lib.flatten;
          };
        }
      ]
    )
    |> lib.attrsets.mergeAttrsList;
in
{
  darwinModules = mkModules ./darwin;
  nixosModules = mkModules ./nixos;
  sharedModules = mkModules ./shared;

  lib = {
    inherit mkModule mkModules;
  };
}
