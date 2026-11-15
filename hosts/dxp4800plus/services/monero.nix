{ config, ... }:
let
  containerIp = "10.100.0.10";
  vpn = config.networking.airvpn;
  p2pPort = 19891;
  restrictedRpcPort = 18089;
in
{
  networking.airvpn.clients.monero.forwardedPort = p2pPort;

  services.newt.blueprint = {
    private-resources = {
      monero = {
        name = "Monero RPC";
        mode = "host";
        destination = containerIp;
        tcp-ports = toString restrictedRpcPort;
        alias = "monero.vanstraten.cloud";
      };
    };
  };

  containers.monero = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/var/lib/monero" = {
        hostPath = "/tank/blockchains/monero";
        isReadOnly = false;
      };
    };

    config = {
      services.monero = {
        enable = true;
        extraConfig = ''
          # Peers connect back to the AirVPN exit on the port we listen on.
          p2p-bind-port=${toString p2pPort}
          no-igd=1
          no-zmq=1
          enable-dns-blocklist=1

          rpc-restricted-bind-ip=0.0.0.0
          rpc-restricted-bind-port=${toString restrictedRpcPort}
          confirm-external-bind=1
        '';
      };

      networking = {
        nameservers = [ vpn.dns ];

        firewall.allowedTCPPorts = [
          p2pPort
          restrictedRpcPort
        ];
      };
    };
  };
}
