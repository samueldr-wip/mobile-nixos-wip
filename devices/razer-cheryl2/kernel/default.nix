{
  mobile-nixos
, fetchFromGitHub
, kernelPatches ? [] # FIXME
, buildPackages
}:

let
  inherit (buildPackages) dtc;
in

# Vendor builds with gcc 4.9 → "gcc version 4.9.x 20150123"
(mobile-nixos.kernel-builder-gcc49 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "4.9.112";
  src = /Users/samuel/tmp/linux/razer-aura-vendor;

  patches = [
    #./0001-mobile-nixos-Adds-and-sets-BGRA-as-default.patch
    ./0001-mobile-nixos-Workaround-selected-processor-does-not-.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  makeFlags = [
    "DTC_EXT=${dtc}/bin/dtc"
  ];

  isModular = false;
}).overrideAttrs({ postInstall ? "", postPatch ? "", nativeBuildInputs, ... }: {
  installTargets = [
    # uh, things seem screwey with that vendor kernel tree, and dependencies
    # are not resolved as expected, so let's ask for the compressed kernel
    # explictly first :/.
    "Image.gz"
    "zinstall"
    "Image.gz-dtb"
    "install"
  ];
  postPatch = postPatch + ''
    # FIXME : factor out
    (
    # Remove -Werror from all makefiles
    local i
    local makefiles="$(find . -type f -name Makefile)
    $(find . -type f -name Kbuild)"
    for i in $makefiles; do
      sed -i 's/-Werror-/-W/g' "$i"
      sed -i 's/-Werror=/-W/g' "$i"
      sed -i 's/-Werror//g' "$i"
    done
    )
  '';
  nativeBuildInputs = nativeBuildInputs ++ [ dtc ];

  postInstall = postInstall + ''
    cp -v "$buildRoot/arch/arm64/boot/Image.gz-dtb" "$out/"
  '';
})
