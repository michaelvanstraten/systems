{ nixpkgs, ... }@inputs':
let
  inherit (nixpkgs.lib.attrsets) recursiveUpdate;
  inherit (nixpkgs.lib.filesystem) listFilesRecursive;
in
{
  directory,
  inputs ? inputs',
  outputPattern ? ".*/outputs\\.nix$",
}:
let
  isOutputFile = path: (builtins.match outputPattern path) != null;
  evaluateOutputFile = outputFile: import outputFile inputs;
in
listFilesRecursive directory
|> builtins.map (path: builtins.toString path)
|> builtins.filter isOutputFile
|> builtins.map evaluateOutputFile
|> builtins.foldl' recursiveUpdate { }
