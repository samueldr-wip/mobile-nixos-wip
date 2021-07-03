{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, ...
}:

let
  sdrPatch = rev: sha256: fetchpatch {
    url = "https://github.com/samueldr/linux/commit/${rev}.patch";
    inherit sha256;
  };
in
mobile-nixos.kernel-builder {
  version = "5.13.0";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    rev = "v5.13";
    sha256 = "1bgcicq01sqwshzn9s730fw30756sqg5wdm6mraxmf131xn3vmim";
  };

  patches = [
    ./0001-gru-Force-hs200-for-eMMC.patch
    ./0001-Revert-drm-atomic-Take-the-atomic-toys-away-from-X.patch

    # usb: dwc3: Enable userspace role switch control 
    (sdrPatch "03aedba687e2aacb258aa0f92876c48f5bde30e7" "09701lbb06daix9cs22yf0nm8wvb7cmybh19s2lbr0b5fn9s73fh")

    # phy: rockchip-inno-usb2: rockchip: Update phy_sus
    (sdrPatch "31585eed614a526324dec66f690fad3fc52dd419" "0hxmrf9y2rrv9nisy2f5cgikkz6fsi1m42fwl36g22x8z393gyjb")

    # WIP: usb: dwc3: Force output B_sessionvalid asserted
    # (While WIP, it is because it is extremely gru-centric...)
    (sdrPatch "9dc445c2e4370be3eb19ee49fd0f4319d91e8631" "1fc7dr5fybnxpfnmdil91d891qvqycpad6anrix7cbzjvflifas6")

    # arm64: dts: rockchip: Set type-c port to OTG and enable role switch for gru-scarlet
    (sdrPatch "cbe4e04bf85d8d37058f89853a8ac0ad518a3e42" "139a9pkaya41nkar3mbcvfvg3xnxr3cr9ja9b320r2cn4qnrbjjc")
    
    # Work around regression that breaks DRM on asus-dumo (scarlet).
    ./0001-Revert-arm64-dts-rockchip-fix-pd_tcpc0-and-pd_tcpc1-.patch
  ];

  isModular = false;
  isCompressed = false;
}
