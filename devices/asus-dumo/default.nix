{ config, lib, pkgs, ... }:

{
  imports = [
    ./mainline.nix
    ./vendor.nix
  ];

  mobile.device.name = "asus-dumo";
  mobile.device.identity = {
    name = "Chromebook Tablet CT100PA";
    manufacturer = "Asus";
  };

  mobile.hardware = {
    soc = "rockchip-op1";
    ram = 1024 * 4;
    screen = {
      width = 1536; height = 2048;
    };
  };

  mobile.system.depthcharge.kpart = {
    dtbs = pkgs.runCommandNoCC "asus-dumo-dtbs" { } ''
      mkdir -p $out
      cp -t $out/ ${config.mobile.boot.stage-1.kernel.package}/dtbs/rockchip/rk3399-gru-scarlet*dtb
    '';
  };

  # Serial console on ttyS2, using a suzyqable or equivalent.
  boot.kernelParams = [
    "console=ttyS2,115200n8"
    "earlyprintk=ttyS2,115200n8"
    "vt.global_cursor_default=0"
  ];

  mobile.system.type = "depthcharge";

  # List of valid provenances
  mobile.boot.stage-1.kernel.availableProvenances = [
    "mainline"
    "vendor"
  ];
}
