{ ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 62518 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
