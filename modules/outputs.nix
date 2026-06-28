{ nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;

  mkModule =
    modulePath: overrides:
    let
      module = import modulePath;
      isFlakeModule =
        module:
        builtins.isFunction module
        && (builtins.functionArgs module |> builtins.intersectAttrs inputs) != { };
    in
    if isFlakeModule module then module (inputs // overrides) else module;

  collectModulePaths =
    dir:
    let
      entries = builtins.readDir dir;
    in
    if entries ? "default.nix" then
      [ dir ]
    else
      entries
      |> lib.attrsToList
      |> lib.concatMap (
        { name, value }:
        let
          path = dir + "/${name}";
        in
        if value == "directory" then
          collectModulePaths path
        else if lib.hasSuffix ".nix" name then
          [ path ]
        else
          [ ]
      );

  mkModules =
    dir:
    collectModulePaths dir
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
      {
        ${moduleName} = mkModule module { };
      }
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
