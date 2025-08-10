{ self, nixpkgs, ... }:
{ config, lib, ... }:
let
  cfg = config.nix.autoDiscoverBuildMachines;
in
{
  options.nix.autoDiscoverBuildMachines = {
    enable = lib.mkEnableOption "Automatically configure Nix build machines from the flake's nixosConfigurations when remote builders are enabled on those hosts";

    sshKey = lib.mkOption {
      type = lib.types.str;
      default = "/var/root/.ssh/keys/nixremote";
      description = "Path to the private SSH key used to connect to remote build machines.";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      # Filter the NixOS configurations to include only those with remote builders enabled
      remoteBuilders =
        self.nixosConfigurations
        |> builtins.attrValues
        |> builtins.filter (
          nixpkgs.lib.attrsets.hasAttrByPath [
            "config"
            "nix"
            "remoteBuilder"
            "enable"
          ]
        )
        |> builtins.filter (host: host.config.nix.remoteBuilder.enable);
    in
    {
      nix = {
        buildMachines = map (host: {
          inherit (host.config.nix.remoteBuilder) supportedFeatures;
          hostName = host.config.networking.hostName;
          system = host.pkgs.system;
          protocol = "ssh-ng";
          sshUser = "nixremote";
          sshKey = cfg.sshKey;
        }) remoteBuilders;

        distributedBuilds = true;
      };
    }
  );
}
