{ ... }@inputs:
modulePath: _:
let
  module = import modulePath;
  isFlakeModule =
    module:
    builtins.isFunction module
    && (builtins.functionArgs module |> builtins.intersectAttrs inputs) != { };
in
if isFlakeModule module then module inputs else module
