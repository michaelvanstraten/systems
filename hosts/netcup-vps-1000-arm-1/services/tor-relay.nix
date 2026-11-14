{
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ContactInfo = "michael@vanstraten.de";
      Nickname = "Talus";
      ORPort = 37801;
      BandWidthRate = "128 MBytes";
    };
  };
}
