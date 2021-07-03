{
  mobile-nixos
, fetchFromGitiles
, ...
}:

mobile-nixos.kernel-builder {
  version = "4.4.274";

  configfile = ./config.aarch64;

  src = fetchFromGitiles {
    url = "https://chromium.googlesource.com/chromiumos/third_party/kernel";
    rev = "69714497950710848e8ae7cc6bac695d03a0ba6b";
    sha256 = "0awanc2h6wk9pv10hpw8z8cxva5my1zbr058lmx7c2dp2flkq5ld";
  };

  patches = [
    ./0001-mobile-nixos-Workaround-selected-processor-does-not-.patch
    ./0002-rockchip-vpu-Fix-duplicate-const-declaration-specifi.patch
    ./0003-rkisp1-dev-Fix-format-d-expects-argument-of-type-int.patch
    ./0004-HACK-trace-firmware-loads-and-filp_open.patch
    ./0005-scarlet-Don-t-wake-on-pen-events.patch
  ];

  isModular = true;
  isCompressed = false;
}
