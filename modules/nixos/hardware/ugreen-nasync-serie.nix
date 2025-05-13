{ pkgs, ... }:
{
  # Ugreen LEDs
  boot.kernelModules = [ "i2c-dev" ];
  environment.systemPackages = [
    pkgs.ugreen-leds-cli
  ];
}
