{ self, ... }:
let
  # Filter the NixOS configurations to include only those with remote builders enabled
  remoteBuilders =
    self.nixosConfigurations
    |> builtins.attrValues
    |> builtins.filter (host: host.config.nix.remoteBuilder.enable);

  # Helper function to generate a list of "Port <number>" strings
  mkPorts = ports: ports |> map (port: "Port ${toString port}") |> builtins.concatStringsSep "\n";

  # Helper function to generate SSH configuration for a single host
  mkHost = host: ''
    Host ${host.config.networking.fqdn}
      HostName ${host.config.networking.fqdn}
      ${mkPorts host.config.services.openssh.ports}
  '';

  # Helper function to generate Nix build machine host.configuration for a single host
  mkBuildMachine = host: {
    hostName = host.config.networking.fqdn;
    system = host.pkgs.system;
    protocol = "ssh-ng";
    sshUser = "nixremote";
    sshKey = "/var/root/.ssh/keys/nixremote";
  };
in
_: {
  environment.etc = {
    # Generate the SSH configuration file for Nix build hosts
    "ssh/ssh_config.d/99-nix-build-hosts.conf" = {
      text = builtins.concatStringsSep "\n\n" (map mkHost remoteBuilders);
    };
  };

  # Configure Nix to use the remote builders
  nix = {
    buildMachines = map mkBuildMachine remoteBuilders;
    distributedBuilds = true;
  };
}
