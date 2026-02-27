{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    kernelModules = [
      "kvm-intel"
      "i2c-dev" # Required for Ugreen LED control
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

  hardware.cpu.intel.updateMicrocode = true;

  powerManagement.powertop.enable = true;

  services.udev.extraRules =
    let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in
    mkRules ([
      # Spin down rotational drives after 10 minutes of inactivity
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -S 120 /dev/%k"''
      ])
    ]);

  environment.systemPackages = [
    pkgs.ugreen-leds-cli
  ];
}
