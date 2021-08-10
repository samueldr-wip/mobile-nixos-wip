{ config, lib, pkgs, ... }:

{
  mobile.device.name = "zte-campbell";
  mobile.device.identity = {
    # AKA Cymbal 2 (8GB) / Telus and Koodo
    # The other Cymbal 2 (4GB) is Z2335CA and is not compatible.
    name = "Z2335L";
    manufacturer = "ZTE";
  };

  mobile.hardware = {
    # Officially listed as msm8937 (software compatible)
    soc = "qualcomm-qm215";
    ram = 1024 * 1;
    # There's an additional secondary screen
    screen = {
      width = 240; height = 320;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.system.android.device_name = "campbell";
  mobile.system.android = {
    # This device has an A/B partition scheme.
    ab_partitions = true;
    # Actually uses a super partition

    bootimg.flash = {
      offset_base = "0x80000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "2048";
    };
  };

  boot.kernelParams = [
    # Extracted from an Android boot image
    # "console=ttyMSM0,115200,n8"
    # "androidboot.console=ttyMSM0"
    # "androidboot.hardware=qcom"
    # "androidboot.memcg=true"
    # "user_debug=30"
    # "msm_rtb.filter=0x237"
    # "ehci-hcd.park=3"
    # "androidboot.bootdevice=7824900.sdhci"
    # "lpm_levels.sleep_disabled=1"
    # "earlycon=msm_hsl_uart,0x78B0000"
    # "vmalloc=300M"
    # "androidboot.usbconfigfs=true"
    # "cgroup.memory=nokmem,nosocket"
    # "loop.max_part=7"
    # "buildvariant=user"
  ];

  mobile.system.type = "android";

  mobile.usb.mode = "gadgetfs";

  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus 4"
  mobile.usb.idProduct = "D001";

  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    rndis = "rndis_bam.rndis";
    mass_storage = "mass_storage.0";
  };

  mobile.boot.stage-1.bootConfig = {
    # Used by target-disk-mode to share the internal drive
    storage.internal = "/dev/disk/by-partlabel/userdata";
  };
}
