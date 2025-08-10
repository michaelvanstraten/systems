{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    # Ugreen LEDs
    kernelModules = [
      "kvm-intel"
      "i2c-dev"
    ];

    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "ahci"
      "usbhid"
      "uas"
      "sd_mod"
    ];
  };

  environment.systemPackages = [
    pkgs.ugreen-leds-cli
  ];

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostId = "4831eedc";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.powertop.enable = true;

  services.udev.extraRules =
    let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in
    mkRules ([
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"''
      ])
    ]);
}
