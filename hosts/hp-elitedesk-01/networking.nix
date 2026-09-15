{
  networking.useDHCP = false;
  networking.hostId = "4831eedc"; # Required for ZFS
  networking.hostName = "hp-elitedesk-01";

  boot.kernelModules = [ "br_netfilter" ];
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  systemd.network = {
    enable = true;

    networks = {
      "10-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "yes";
      };
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "eno1";
  };
}
