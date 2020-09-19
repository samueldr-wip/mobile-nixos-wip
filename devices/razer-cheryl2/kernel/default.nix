{
  mobile-nixos
, fetchFromGitHub
, kernelPatches ? [] # FIXME
, buildPackages
}:

let
  inherit (buildPackages) dtc;
in

(mobile-nixos.kernel-builder-gcc49 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "4.9.112";
  # FIXME: host under mobile-nixos org
  # FIXME: Factor out patches from official dump
  src = fetchFromGitHub {
    owner = "samueldr";
    repo = "linux";
    rev = "08abfe32a9988ad87bf5601eaff22aec94077278"; # Known good
    sha256 = "0al49vp51i4zy4a0q9my6kg9s4q95fi0d8ipnm48a3csljyggrzp";
  };

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
