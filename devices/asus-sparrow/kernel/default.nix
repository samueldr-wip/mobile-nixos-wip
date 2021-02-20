{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, ...
}:

let
  asteroidosPatch = file: sha256: fetchpatch {
    inherit sha256;
    url = let rev = "7d61c170d0ad0256674be21225205b845058a5c7"; in
      "https://raw.githubusercontent.com/AsteroidOS/meta-sparrow-hybris/${rev}/recipes-kernel/linux/linux-sparrow/${file}";
  };
in
mobile-nixos.kernel-builder-gcc8 {
  version = "3.10.40";
  configfile = ./config.armv7;

  src = fetchFromGitHub {
    owner = "samueldr";
    repo = "linux";
    rev = "ef67837e3ce5ef5731cb6645de321e7743fd1ef4"; # android-wear-7.1.1_r0.33
    sha256 = "10qz0xzsxrhdvb198hk6hh73xp010sl3m14lg46jplx7653gh0fh";
  };

  patches = [
    ./0001-mobile-nixos-Adds-and-sets-BGRA-as-default.patch
    ./0001-it7260_ts_i2c-Silence.patch
    ./05_dtb-fix.patch
    ./90_dtbs-install.patch
    (asteroidosPatch "0002-static-inline-in-ARM-ftrace.h.patch" "10mk3ynyyilwg5gdkzkp51qwc1yn0wqslxdpkprcmsrca1i8ms3y")
    (asteroidosPatch "0005-Patch-battery-values.patch" "09gpkcxxd388b12sr8lsq6hwkqmnil0p9m6yk6zxhszrk89j7iby")
    (asteroidosPatch "0009-Makefile-patch-fixes-ASUS_SW_VER-error.patch" "0mg54499imrcwhn8qbj1sdysh4q1qc2iwmgy57kwz5wrvg3cr3i0")
    (asteroidosPatch "0011-ARM-uaccess-remove-put_user-code-duplication.patch" "044x5bms8rww4f4l8xkf2g5hashmdknlalk2im9al9b87p1x708m")
  ];

  isModular = false;
  isQcdt = true;
  qcdt_dtbs = "arch/arm/boot/";

  # Things are seemingly wrong in that kernel build with parallelization...
  enableParallelBuilding = false;

  # Fixes for building with gcc 8
  postPatch = ''
    echo "#include <linux/compiler-gcc6.h>" > include/linux/compiler-gcc7.h
    echo "#include <linux/compiler-gcc7.h>" > include/linux/compiler-gcc8.h
  '';
  enableCompilerGcc6Quirk = true;
}
