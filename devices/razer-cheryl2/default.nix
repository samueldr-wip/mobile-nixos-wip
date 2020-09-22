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
    "video=vfb:640x400,bpp=32,memsize=3072000"
    "hellorazer=hi_1"
    "console=tty1"
    "quiet"
  ];

  mobile.system.type = "android";

  mobile.usb.mode = "gadgetfs";
  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus 4"
  mobile.usb.idProduct = "D001";

  mobile.usb.gadgetfs.functions = {
    rndis = "gsi.rndis";
  };

  # for f in *channel*/brightness *channel*/led_current; do echo 25 > $f; done
  mobile.boot.stage-1.tasks = [
    # This dims the display during boot.
    # This is used as a temporary measure to let the user know the boot is going fine.
    #(pkgs.writeText "dim-display.rb" ''
    #  class Tasks::DimDisplayAtBoot < SingletonTask
    #    DRIVER = "/sys/class/leds/wled"

    #    def initialize()
    #      add_dependency(:Mount, "/sys")
    #      add_dependency(:Files, DRIVER)
    #    end

    #    def run()
    #      # ~10%... probably not if the driver is not linear.
    #      System.write(File.join(DRIVER, "brightness"), (0.10*4095).to_s)
    #      System.sleep(0.1)
    #      System.write(File.join(DRIVER, "brightness"), (0.10*4095).to_s)
    #      System.sleep(0.1)
    #      System.write(File.join(DRIVER, "brightness"), (0.10*4095).to_s)
    #      System.sleep(0.1)
    #    end
    #  end
    #'')

    # This activates the vibrator during boot.
    # This is used as a temporary measure to let the user know the boot is going fine.
    (pkgs.writeText "vibrate.rb" ''
      class Tasks::VibrateAtBoot < SingletonTask
        DRIVER = "/sys/class/leds/vibrator/"

        def initialize()
          add_dependency(:Mount, "/sys")
          add_dependency(:Files, DRIVER)
        end

        def brrrr(duration)
          System.write(File.join(DRIVER, "duration"), duration.to_s)
          System.write(File.join(DRIVER, "activate"), "1")
        end

        def run()
          brrrr(200)
          System.sleep(0.6)
          brrrr(500)
          System.sleep(0.6)
          brrrr(200)
        end
      end
    '')
  ];
}
