{ config, ... }:
{
  sops.secrets."newt/id" = { };
  sops.secrets."newt/secret" = { };

  sops.templates."newt.env" = {
    content = ''
      NEWT_ID=${config.sops.placeholder."newt/id"}
      NEWT_SECRET=${config.sops.placeholder."newt/secret"}
    '';
  };

  containers.newt = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.2/24";

    bindMounts = {
      "/run/secrets/newt.env" = {
        hostPath = config.sops.templates."newt.env".path;
        isReadOnly = true;
      };
    };

    config = {
      system.stateVersion = "26.05";

      networking.defaultGateway = "10.100.0.1";
      networking.useHostResolvConf = false;
      networking.nameservers = [
        "1.1.1.1"
        "9.9.9.9"
      ];

      services.newt = {
        enable = true;
        settings = {
          endpoint = "https://pangolin.vanstraten.cloud";
        };
        environmentFile = "/run/secrets/newt.env";
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      51820
      21820
    ];
  };

}
