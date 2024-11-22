inputs: {
  lib = {
    callModule = import ./callModule.nix inputs;
    callOutputs = import ./callOutputs.nix inputs;
    darwin = import ./darwin.nix inputs;
    modulesFromDirectoryRecursive = import ./modulesFromDirectoryRecursive.nix inputs;
  };
}
