inputs: {
  lib = {
    callModule = import ./callModule.nix inputs;
    callOutputs = import ./callOutputs.nix inputs;
    modulesFromDirectoryRecursive = import ./modulesFromDirectoryRecursive.nix inputs;
  };
}
