{ config, lib, pkgs, ... }:
let
  inherit (config.mobile.device) name;
in {
  mobile.device.name = "xiaomi-davinci";
  mobile.device.info = {
    name = "Xiaomi Mi 9T / Redmi K20";
    screen_width = 1080;
    screen_height = 2340;

    #BOARD_KERNEL_CMDLINE console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=1 androidboot.usbcontroller=a600000.dwc3 firmware_class.path=/vendor/firmware_mnt/image earlycon=msm_geni_serial,0x880000 loop.max_part=7 cgroup.memory=nokmem,nosocket androidboot.selinux=permissive buildvariant=eng
    #BOARD_KERNEL_BASE 00000000
    #BOARD_NAME 
    #BOARD_PAGE_SIZE 4096
    #BOARD_HASH_TYPE sha1
    #BOARD_KERNEL_OFFSET 00008000
    #BOARD_RAMDISK_OFFSET 01000000
    #BOARD_SECOND_OFFSET 00f00000
    #BOARD_TAGS_OFFSET 00000100
    #BOARD_OS_VERSION 16.1.0
    #BOARD_OS_PATCH_LEVEL 2099-12
    #BOARD_HEADER_VERSION 1
    #BOARD_RECOVERY_DTBO_SIZE 3863219
    #BOARD_RECOVERY_DTBO_OFFSET 34291712
    #BOARD_HEADER_SIZE 1648

    kernel_cmdline = "console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=1 androidboot.usbcontroller=a600000.dwc3 firmware_class.path=/vendor/firmware_mnt/image earlycon=msm_geni_serial,0x880000 loop.max_part=7 cgroup.memory=nokmem,nosocket androidboot.selinux=permissive buildvariant=eng";
    flash_offset_base = "0x80000000";
    flash_offset_kernel = "0x00008000";
    flash_offset_second = "0x00f00000";
    flash_offset_ramdisk = "0x01000000";
    flash_offset_tags = "0x00000100";
    flash_pagesize = "4096";
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
