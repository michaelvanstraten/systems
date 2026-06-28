{
  config,
  lib,
  ...
}@host:
let
  journalDir = "/var/log/journal";

  machineId = name: builtins.hashString "md5" "nixos-container:${name}";

  defaultHostBridge = "br-containers";
  defaultGateway = "10.100.0.1";
  defaultNameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  workaroundContainers = lib.filterAttrs (_: c: c.journalHostWorkaround) config.containers;
in
{
  options.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options.journalHostWorkaround = lib.mkEnableOption ''
            Enable workaround to <https://github.com/systemd/systemd/issues/39302>
          '';

          config = lib.mkMerge [
            {
              journalHostWorkaround = lib.mkDefault true;

              autoStart = lib.mkDefault true;
              privateNetwork = lib.mkDefault true;

              hostBridge = lib.mkDefault defaultHostBridge;

              config = {
                networking = {
                  useNetworkd = lib.mkDefault true;
                  useHostResolvConf = lib.mkOverride 900 false;
                  nameservers = lib.mkDefault defaultNameservers;
                };

                systemd.network.networks."10-eth0" =
                  lib.mkIf (config.localAddress != null && config.hostBridge == defaultHostBridge)
                    {
                      matchConfig.Name = lib.mkDefault "eth0";
                      networkConfig = {
                        Address = lib.mkDefault config.localAddress;
                        Gateway = lib.mkDefault defaultGateway;
                        DHCP = lib.mkDefault "no";
                        LinkLocalAddressing = lib.mkDefault "no";
                      };
                    };

                system.stateVersion = host.config.system.stateVersion;
              };
            }

            (lib.mkIf config.journalHostWorkaround (
              let
                dir = "${journalDir}/${machineId name}";
              in
              {
                extraFlags = [ "--link-journal=no" ];

                bindMounts.${dir} = {
                  hostPath = dir;
                  isReadOnly = false;
                };

                # The mechanism relies on journald writing to /var/log/journal
                # (the NixOS default); be explicit about it. The matching,
                # deterministic machine-id is pinned from the host in the
                # `container@${name}` preStart below.
                config.services.journald.storage = "persistent";
              }
            ))
          ];
        }
      )
    );
  };

  config = {
    systemd.tmpfiles.rules = lib.mapAttrsToList (
      name: _: "d ${journalDir}/${machineId name} 2755 root systemd-journal - -"
    ) workaroundContainers;

    # Pin each container's machine-id to the deterministic value the journal
    # bind mount expects, writing a plain /etc/machine-id from the host before
    # the container boots. Doing this via the container's `environment.etc`
    # would instead create a read-only store symlink, which breaks
    # nixos-containers' `touch "$root/etc/machine-id"`. This also self-heals a
    # container that still carries a stale symlink or a different machine-id.
    systemd.services = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "container@${name}" {
        preStart = lib.mkBefore ''
          machineIdFile="/var/lib/nixos-containers/${name}/etc/machine-id"
          wantedMachineId="${machineId name}"
          if [ -L "$machineIdFile" ] || [ "$(cat "$machineIdFile" 2>/dev/null)" != "$wantedMachineId" ]; then
            rm -f "$machineIdFile"
            mkdir -p "/var/lib/nixos-containers/${name}/etc"
            printf '%s\n' "$wantedMachineId" > "$machineIdFile"
          fi
        '';
      }
    ) workaroundContainers;

    assertions =
      let
        addressed = lib.filterAttrs (_: c: c.localAddress != null) config.containers;
        keyOf = c: "${toString c.hostBridge} ${c.localAddress}";
        byAddress = lib.groupBy (name: keyOf addressed.${name}) (lib.attrNames addressed);
      in
      lib.mapAttrsToList (key: names: {
        assertion = lib.length names == 1;
        message = "containers ${lib.concatStringsSep ", " names} share the same hostBridge/localAddress (${key})";
      }) byAddress;
  };
}
