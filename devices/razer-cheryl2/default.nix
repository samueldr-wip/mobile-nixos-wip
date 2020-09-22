{ config, lib, pkgs, ... }:

{
  mobile.device.name = "razer-cheryl2";
  mobile.device.identity = {
    name = "Razer Phone 2";
    manufacturer = "Razer";
  };

  mobile.hardware = {
    soc = "qualcomm-sdm845";
    ram = 1024 * 8;
    screen = {
      width = 1440; height = 2560;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
  };

  mobile.system.android = {
    # This device has an A/B partition scheme
    ab_partitions = true;

    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  mobile.system.vendor.partition = "/dev/disk/by-partlabel/vendor_a";

  boot.kernelParams = [
    # From TWRP
    "console=ttyMSM0,115200n8"
    "earlycon=msm_geni_serial,0xA84000"
    "androidboot.hardware=qcom"
    "androidboot.console=ttyMSM0"
    "video=vfb:640x400,bpp=32,memsize=3072000"
    "msm_rtb.filter=0x237"
    "ehci-hcd.park=3"
    "lpm_levels.sleep_disabled=1"
    "service_locator.enable=1"
    "swiotlb=2048"
    "androidboot.configfs=true"
    #"firmware_class.path=/vendor/firmware_mnt/image"
    "loop.max_part=7"
    "androidboot.usbcontroller=a600000.dwc3"
    "buildvariant=user"
    "printk.devkmsg=on"


    # Using `quiet` fixes early framebuffer init, for stage-1
    "quiet"
  ];

  mobile.system.type = "android";

  mobile.usb.mode = "gadgetfs";
  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus 4"
  mobile.usb.idProduct = "D001";

  mobile.usb.gadgetfs.functions = {
    #rndis = "gsi.rndis";
    # FIXME: This is the right function name, but doesn't work.
    # adb = "ffs.usb0";
  };
}
