{
  networking = {
    bridges.br0.interfaces = [ "enp6s0" ];
    useDHCP = false;
    interfaces."br0" = {
      useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.178.201";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.1" ];
  };

  containers.k8s-master-1 = {
    autoStart = true;
    config = ./nodes/master-01;
    enableTun = true;
    hostBridge = "br0";
    localAddress = "192.168.178.202/24";
    privateNetwork = true;
    privateUsers = "pick";
  };
}
