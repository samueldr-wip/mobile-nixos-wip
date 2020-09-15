{ config, lib, pkgs, ... }:

{
  mobile.device.name = "razer-phone";
  mobile.device.identity = {
    name = "Razer Phone";
    manufacturer = "Razer";
  };

  mobile.hardware = {
    soc = "qualcomm-msm8998";
    ram = 1024 * 8;
    screen = {
      width = 1440; height = 2560;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
  };

  mobile.system.android.bootimg = {
    flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  boot.kernelParams = [
    "androidboot.hardware=qcom"
    "user_debug=31"
    "msm_rtb.filter=0x237"
    "ehci-hcd.park=3"
    "lpm_levels.sleep_disabled=1"
    "cma=32M@0-0xffffffff"
    "androidboot.selinux=permissive"
    "buildvariant=eng"
  ];

  mobile.usb.mode = "android_usb";
  # Razer
  mobile.usb.idVendor = "1532";
  # "Razer Phone"
  mobile.usb.idProduct = "9051";

  mobile.system.type = "android";

}
