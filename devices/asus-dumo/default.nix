{ config, lib, pkgs, ... }:

{
  mobile.device.name = "asus-dumo";
  mobile.device.identity = {
    name = "Chromebook Tablet CT100PA";
    manufacturer = "Asus";
  };

  mobile.hardware = {
    soc = "rockchip-op1";
    ram = 1024 * 4;
    screen = {
      width = 1536; height = 2048;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel {};
  };

  mobile.system.depthcharge.kpart = {
    dtbs = pkgs.runCommandNoCC "asus-dumo-dtbs" { } ''
      mkdir -p $out
      cp -t $out/ ${config.mobile.boot.stage-1.kernel.package}/dtbs/rockchip/rk3399-gru-scarlet*dtb
    '';
  };

  # Serial console on ttyS2, using a suzyqable or equivalent.
  boot.kernelParams = [
    "console=ttyS2,115200n8"
    "earlyprintk=ttyS2,115200n8"
    "vt.global_cursor_default=0"
  ];

  mobile.system.type = "depthcharge";

  mobile.device.firmware = pkgs.callPackage ./firmware {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  # The controller is hidden from the OS unless started using the "android"
  # launch option in the weird UEFI GUI chooser.
  mobile.usb.mode = "gadgetfs";

  # Commonly re-used values, Nexus 4 (debug)
  # (These identifiers have well-known default udev rules.)
  mobile.usb.idVendor = "18d1";
  mobile.usb.idProduct = "d002";

  # Mainline gadgetfs functions
  mobile.usb.gadgetfs.functions = {
    rndis = "rndis.usb0";
    mass_storage = "mass_storage.0";
    adb = "ffs.adb";
  };

  mobile.boot.stage-1.bootConfig = {
    # Used by target-disk-mode to share the internal drive
    storage.internal = "/dev/disk/by-path/platform-fe330000.mmc";
  };

  mobile.boot.stage-1.tasks = [
    ./fixup_sdhci_arasan_task.rb
    ./usb_role_switch_task.rb
  ];

  # This makes use of "atomic mode setting".
  # This is needed for proper panel power management.
  # *sigh*
  services.xserver.deviceSection = ''
    Option "Atomic" "True"
  '';

  # `mem` suspend doesn't work.
  # (vendor chromeos-4.4 *and* mainline)
  systemd.sleep.extraConfig = ''
    SuspendState=freeze
  '';
}
