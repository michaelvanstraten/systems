{ nixpkgs, ... }:
let
  inherit (nixpkgs) lib;
in
{
  mkPersistentApps =
    value:
    if !(lib.isList value) then
      value
    else
      map (app: {
        tile-data = {
          file-data = {
            _CFURLString = app;
            _CFURLStringType = 0;
          };
        };
      }) value;
}
