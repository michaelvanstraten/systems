{ ... }:
{
  networking.bridges.br-containers.interfaces = [ ];

  networking.interfaces.br-containers = {
    ipv4.addresses = [
      {
        address = "10.100.0.1";
        prefixLength = 24;
      }
    ];
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "br-containers" ];
    externalInterface = "enp7s0";
  };
}
