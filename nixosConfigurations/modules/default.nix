{ ... }:
{
  system.stateVersion = "25.11";

  console.keyMap = "de";

  imports = [
    ./nix.nix
    ./ssh.nix
    ./users.nix
  ];
}
