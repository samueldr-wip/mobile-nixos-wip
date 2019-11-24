{ config, lib, pkgs, ... }:
let
  inherit (config.mobile.device) name;
in {
  mobile.device.name = "xiaomi-davinci";
  mobile.device.info = {
    name = "Xiaomi Mi 9T / Redmi K20";
    screen_width = 1080;
    screen_height = 2340;
    kernel_cmdline = "androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci earlycon=msm_hsl_uart,0x78af000 androidboot.selinux=permissive buildvariant=eng";
    flash_offset_base = "0x80000000";
    flash_offset_kernel = "0x00008000";
    flash_offset_second = "0x00f00000";
    flash_offset_ramdisk = "0x01000000";
    flash_offset_tags = "0x00000100";
    flash_pagesize = "2048";
    kernel = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
    #dtb = "${kernel}/dtbs/msm8953-qrd-sku3-tissot.dtb";
  };
  mobile.hardware = {
    soc = "qualcomm-sdm730";
    ram = 1024 * 6;
    screen = {
      width = 1080; height = 2340;
    };
  };

  mobile.system.type = "android";
}
