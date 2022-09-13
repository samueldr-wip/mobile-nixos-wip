{ config, lib, pkgs, ... }:

{
  imports = [
    ../families/sdm845-mainline
  ];

  mobile.device.name = "oneplus-fajita";
  mobile.device.identity = {
    name = "OnePlus 6T";
    manufacturer = "OnePlus";
  };

  mobile.hardware = {
    ram = 1024 * 8;
    screen = {
      width = 1080; height = 2340;
    };
  };

  mobile.device.firmware = pkgs.callPackage ../oneplus-enchilada/firmware {};

  mobile.system.android.device_name = "OnePlus6T";
}
