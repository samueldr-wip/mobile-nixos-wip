{ config, lib, pkgs, ... }:

{
  mobile.device.name = "asus-sparrow";
  mobile.device.identity = {
    name = "Zenwatch 2 WI501Q";
    manufacturer = "Asus";
  };

  mobile.hardware = {
    soc = "qualcomm-msm8926";
    ram = 512;
    screen = {
      width = 320; height = 320;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  # mobile.device.firmware = pkgs.callPackage ./firmware {};

  mobile.system.android.bootimg = {
    flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x02000000";
      offset_second = "0x00f00000";
      offset_tags = "0x01e00000";
      pagesize = "2048";
    };
  };

  boot.kernelParams = [
    #"console=ttyHSL0,115200,n8"
    #"androidboot.console=ttyHSL0"
    "androidboot.hardware=sparrow"
    #"user_debug=31"
    #"maxcpus=4"
    #"msm_rtb.filter=0x3F"
    "pm_levels.sleep_disabled=1"
    "selinux=0"
  ];

  mobile.usb.mode = "android_usb";
  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus/Pixel Device (MTP + debug)"
  mobile.usb.idProduct = "4EE2";

  mobile.system.type = "android";

  mobile.quirks.qualcomm.wcnss-wlan.enable = true;
}
