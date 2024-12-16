inputs: {
  lib = {
    callOutputs = import ./callOutputs.nix inputs;
    darwin = import ./darwin.nix inputs;
  };
}
