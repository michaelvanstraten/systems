{ ... }:
{
  users.users.michael = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8OCYTaHjQy7Y7bRmxzVwNBgnD9P21UQPzVpJ3NKwVV"
    ];
    initialPassword = "fsbEh&PzR9Eo";
  };

  security.sudo.wheelNeedsPassword = false;
}
