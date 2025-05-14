{ ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 62518 ];
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only.
      PasswordAuthentication = false;
    };
  };
}
