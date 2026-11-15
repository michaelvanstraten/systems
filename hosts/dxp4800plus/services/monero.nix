{ config, ... }:
let
  containerIp = "10.100.0.10";
  vpn = config.networking.airvpn;
  p2pPort = 19891;
  restrictedRpcPort = 18089;
  exporterPort = 9604;
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

  services.alloy.extraConfig = ''
    prometheus.scrape "monero" {
      targets         = [{ __address__ = "${containerIp}:${toString exporterPort}" }]
      forward_to      = [prometheus.remote_write.default.receiver]
      scrape_interval = "30s"
    }
  '';

  containers.monero = {
    localAddress = "${containerIp}/24";

    bindMounts = {
      "/var/lib/monero" = {
        hostPath = "/tank/blockchains/monero";
        isReadOnly = false;
      };
    };

    config =
      { pkgs, ... }:
      let
        exporter = pkgs.writers.writePython3 "monero-exporter" { } ''
          import json
          import sys
          import urllib.request
          from http.server import BaseHTTPRequestHandler, HTTPServer

          RPC_URL = sys.argv[1]
          PORT = int(sys.argv[2])

          METRICS = {
              "height": ("height", "Height of the local blockchain"),
              "target_height": (
                  "target_height",
                  "Height of the network chain while syncing",
              ),
              "difficulty": ("difficulty", "Current network difficulty"),
              "tx_count": ("tx_count", "Transactions on the blockchain"),
              "tx_pool_size": ("tx_pool_size", "Transactions in the mempool"),
              "incoming_connections_count": (
                  "incoming_connections",
                  "Incoming P2P connections",
              ),
              "outgoing_connections_count": (
                  "outgoing_connections",
                  "Outgoing P2P connections",
              ),
              "rpc_connections_count": (
                  "rpc_connections",
                  "Open RPC connections",
              ),
              "white_peerlist_size": (
                  "white_peerlist_size",
                  "Peers in the white list",
              ),
              "grey_peerlist_size": (
                  "grey_peerlist_size",
                  "Peers in the grey list",
              ),
              "database_size": (
                  "database_size_bytes",
                  "Size of the blockchain database",
              ),
              "synchronized": ("synchronized", "1 if the node is synced"),
              "busy_syncing": ("busy_syncing", "1 if the node is syncing"),
              "offline": ("offline", "1 if the node is in offline mode"),
              "update_available": (
                  "update_available",
                  "1 if a new release is available",
              ),
          }


          def render():
              try:
                  with urllib.request.urlopen(RPC_URL, timeout=10) as response:
                      info = json.load(response)
              except Exception:
                  info = None

              lines = [
                  "# HELP monero_up 1 if monerod RPC is reachable",
                  "# TYPE monero_up gauge",
                  f"monero_up {int(info is not None)}",
              ]
              for key, (name, help_text) in METRICS.items():
                  if info is None or key not in info:
                      continue
                  lines += [
                      f"# HELP monero_{name} {help_text}",
                      f"# TYPE monero_{name} gauge",
                      f"monero_{name} {int(info[key])}",
                  ]
              return "\n".join(lines) + "\n"


          class Handler(BaseHTTPRequestHandler):
              def do_GET(self):
                  if self.path != "/metrics":
                      self.send_error(404)
                      return
                  body = render().encode()
                  self.send_response(200)
                  self.send_header(
                      "Content-Type", "text/plain; version=0.0.4"
                  )
                  self.send_header("Content-Length", str(len(body)))
                  self.end_headers()
                  self.wfile.write(body)

              def log_message(self, *args):
                  pass


          HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
        '';
      in
      {
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

        systemd.services.monero-exporter = {
          wantedBy = [ "multi-user.target" ];
          after = [ "monero.service" ];
          serviceConfig = {
            ExecStart = "${exporter} http://127.0.0.1:${toString restrictedRpcPort}/get_info ${toString exporterPort}";
            DynamicUser = true;
            Restart = "always";
          };
        };

        networking = {
          nameservers = [ vpn.dns ];

          firewall.allowedTCPPorts = [
            p2pPort
            restrictedRpcPort
            exporterPort
          ];
        };
      };
  };
}
