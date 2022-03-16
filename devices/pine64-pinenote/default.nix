{ config, lib, pkgs, ... }:
{
  mobile.device.name = "pine64-pinenote";
  mobile.device.identity = {
    name = "PineNote";
    manufacturer = "Pine64";
  };

  boot.kernelParams = [
    "earlycon=uart8250,mmio32,0xfe660000"
    "earlyprintk"

    # Black on white fbcon
    "vt.default_red=0xFF,0xBC,0x4F,0xB4,0x56,0xBC,0x4F,0x00,0xA1,0xCF,0x84,0xCA,0x8D,0xB4,0x84,0x68"
    "vt.default_grn=0xFF,0x55,0xBA,0xBA,0x4D,0x4D,0xB3,0x00,0xA0,0x8F,0xB3,0xCA,0x88,0x93,0xA4,0x68"
    "vt.default_blu=0xFF,0x58,0x5F,0x58,0xC5,0xBD,0xC5,0x00,0xA8,0xBB,0xAB,0x97,0xBD,0xC7,0xC5,0x68"

    # It's good enough without this; the running application will need to
    # do a full screen refresh anyway to make the image pristine.
    "rockchip_ebc.skip_reset=1"
  ];

  # Serial console on ttyS2, using the adapter dongle.
  mobile.boot.serialConsole = "ttyS2,115200n8";

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.hardware = {
    soc = "rockchip-rk3566";
    ram = 1024 * 4;
    eink.enable = true;
    screen = {
      width = 1404; height = 1872;
    };
  };

  # Through Tow-Boot
  mobile.system.type = "u-boot";

  mobile.device.firmware = pkgs.callPackage ./firmware {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  mobile.usb.mode = "gadgetfs";

  # It seems Pine64 does not have an idVendor...
  mobile.usb.idVendor = "1209";  # http://pid.codes/1209/
  mobile.usb.idProduct = "0069"; # "common tasks, such as testing, generic USB-CDC devices, etc."

  # Mainline gadgetfs functions
  mobile.usb.gadgetfs.functions = {
    rndis = "rndis.usb0";
    mass_storage = "mass_storage.0";
    adb = "ffs.adb";
  };

  mobile.boot.stage-1.bootConfig = {
    # Used by target-disk-mode to share the internal drive
    storage.internal = "/dev/disk/by-path/platform-fe310000.mmc"; # /aliases/mmc0
  };

  mobile.boot.stage-1.shell.console = "ttyS2";
}
