{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, ufdt-apply-overlay
, ...
}:

/*
Linux version 4.9.218-perf+ (zte@scl_xa242_051) (clang version 8.0.12 for Android NDK) #1 SMP PREEMPT Fri Jul 24 09:38:40 CST 2020
*/

#mobile-nixos.kernel-builder-clang_9 { # (unknown)
mobile-nixos.kernel-builder-clang_8 { # fails to build with armv7l
#mobile-nixos.kernel-builder-gcc49 { # builds fine
  #configfile = ./config.armv7l; # XXX
  configfile = ./config.aarch64;

  version = "4.9.218";
  ##src = fetchFromGitHub {
  ##  owner = "xxxxxxxxx";
  ##  repo = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  ##  rev = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  ##  sha256 = "0000000000000000000000000000000000000000000000000000";
  ##};
  src = builtins.fetchGit /Users/samuel/tmp/linux/zte_campbell;

  makeFlags = [
    "ZTE_BOARD_NAME=campbell"
  ];

  patches = [
    ./0001-mobile-nixos-Workaround-selected-processor-does-not-.patch
    ./0001-mobile-nixos-Adds-and-sets-BGRA-as-default.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  nativeBuildInputs = [
    ufdt-apply-overlay
  ];

  enableRemovingWerror = true;
  isImageGzDtb = true;
  isModular = false;
  dtboImg = true;
  # ^XXX armv7l set to false
  # Only relevant with AArch64 AFAICT

  # fixdep: error opening depfile: [...]: No such file or directory
  #enableParallelBuilding = false;
}
