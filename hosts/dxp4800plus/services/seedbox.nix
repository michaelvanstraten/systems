{ ... }:
{
  containers.seedbox = {
    autoStart = true;
    privateNetwork = true;

    hostBridge = "br-containers";
    localAddress = "10.100.0.5/24";

    config = {
      system.stateVersion = "26.05";

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Address = "10.100.0.5/24";
          Gateway = "10.100.0.1";
          DHCP = "no";
          LinkLocalAddressing = "no";
        };
      };

      networking = {
        useNetworkd = true;
        useHostResolvConf = false;
        nameservers = [ "10.100.0.4" ];

        firewall.allowedTCPPorts = [ 8080 ];
      };

      services = {
        qbittorrent = {
          enable = true;
          serverConfig = {
            Preferences = {
              Connection = {
                Proxy = {
                  Type = 2;
                  IP = "10.100.0.4";
                  Port = 1080;
                  AuthEnabled = false;
                  ProxyPeerConnections = true;
                  RSS = true;
                  Misc = true;
                  BitTorrent = true;
                };
              };
            };
          };
        };
        sonarr = {
          enable = true;
          openFirewall = true;
        };
      };
    };
  };
}
