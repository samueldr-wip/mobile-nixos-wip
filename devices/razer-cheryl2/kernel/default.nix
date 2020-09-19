{
  mobile-nixos
, fetchFromGitHub
, kernelPatches ? [] # FIXME
, buildPackages
}:

let
  inherit (buildPackages) dtc;
in

(mobile-nixos.kernel-builder-clang_9 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  src = fetchFromGitHub {
    owner = "arter97";
    repo = "android_kernel_razer_sdm845";
    rev = "231039a3ca33c05b1fc80afcc237061820d3195d";
    sha256 = "1zwklsq45y92dybnyp0axnxqn0bl064304min37if933nlsbjqfd";
  };
  version = "4.9.197";

  patches = [
    ./0001-mobile-nixos-Adds-and-sets-BGRA-as-default.patch
    ./0001-mobile-nixos-Workaround-selected-processor-does-not-.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
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
