{ config, lib, pkgs, ... }:

lib.mkIf (config.mobile.boot.stage-1.kernel.provenance == "mainline")
{
  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel-mainline {};
  };

  mobile.device.firmware = pkgs.callPackage ./firmware-mainline {};
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

  # `mem` suspend doesn't work.
  # `freeze` suspend doesn't work.
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  # This makes use of "atomic mode setting".
  # This is needed for proper panel power management.
  # *sigh*
  services.xserver.deviceSection = ''
    Option "Atomic" "True"
  '';
}
