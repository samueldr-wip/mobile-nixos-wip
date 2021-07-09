{ config, lib, pkgs, ... }:

lib.mkIf (config.mobile.boot.stage-1.kernel.provenance == "vendor")
{
  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel-vendor {};
  };

  mobile.device.firmware = pkgs.callPackage ./firmware-vendor {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  # `mem` suspend doesn't work.
  systemd.sleep.extraConfig = ''
    SuspendState=freeze
  '';

  # This makes use of "atomic mode setting".
  # This is needed for proper panel power management.
  # *sigh*
  services.xserver.deviceSection = ''
    Option "Atomic" "True"
  '';

  # (There is no support for gadget mode in the chromeos-4.4 kernel.)
}
