{ config, lib, pkgs, ... }:

{
  imports = [
    ../oneplus-enchilada/sound.nix
  ];

  mobile.device.name = "google-blueline";
  mobile.device.identity = {
    name = "Pixel 3";
    manufacturer = "Google";
  };

  mobile.hardware = {
    soc = "qualcomm-sdm845";
    ram = 1024 * 4;
    screen = {
      width = 1080; height = 2160;
    };
  };

  mobile.boot.stage-1 = {
    compression = "xz";
    kernel.package = pkgs.callPackage ./kernel-mainline { };
  };

  mobile.device.firmware = pkgs.callPackage ./firmware-mainline {
    vendor-firmware-files = pkgs.callPackage ./firmware-vendor { };
  };
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];
  mobile.boot.stage-1.firmware = [
    # NOTE: putting the full firmware files here risks making the initramfs
    # too big, which is known to break boot.
    # Having the firmware files only in the built system is sufficient.
    # config.mobile.device.firmware
  ];

  mobile.system.android.device_name = "blueline";
  mobile.system.android = {
    # This device has an A/B partition scheme.
    # NOTE: while A/B, we cannot rely on anything else than `boot` as this
    #       device uses dynamic partitions.
    ab_partitions = true;
    boot_as_recovery = false;

    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00000000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  boot.kernelParams = [
    "console=tty0"
    # XXX required to be last or display fails (?!)
    "console=ttyMSM0,115200n8"
  ];

  mobile.usb.mode = "gadgetfs";
  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus 4"
  mobile.usb.idProduct = "D001";

  mobile.system.type = "android";


  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    rndis = "rndis.usb0";
  };

  mobile.quirks.qualcomm.sdm845-modem.enable = true;

  mobile.system.android.system_partition_destination = "userdata";
}
