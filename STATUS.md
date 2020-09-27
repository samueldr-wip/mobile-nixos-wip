This currently **requires** DRM to work.

The "good" kind of DRM.

* * *

Note that this should build and run, but without graphics.

Sample local.nix used for SSH access:

```
{ config, pkgs, ... }:

let
  pkgconfig-helper = with pkgs; writeShellScriptBin "pkg-config" ''
    exec ${buildPackages.pkgconfig}/bin/${buildPackages.pkgconfig.targetPrefix}pkg-config "$@"
  '';
  modeset = pkgs.callPackage ./test.nix {
    pkgconfig = pkgconfig-helper;
  };
in
{
  boot.consoleLogLevel = 8;
  boot.kernelParams = [
    "printk_ratelimit=0"
  ];

  mobile.boot.stage-1.networking.enable = true;

#  # Will "break" boot, but you can ssh in stage-1.
#  mobile.boot.stage-1.shell.enable = true;
#  mobile.boot.stage-1.ssh.enable = true;

  mobile.boot.stage-1.extraUtils = with pkgs; [
    { package = modeset; /*extraCommand = "cp -fpv ${glibc.out}/lib/libnss_files.so.* $out/lib";*/ }
  ];
}
```
