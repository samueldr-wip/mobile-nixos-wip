{
  mobile-nixos
, kernelPatches ? [] # FIXME
, buildPackages
, dtbTool
}:

let
  inherit (buildPackages) dtc;
in

(mobile-nixos.kernel-builder-gcc49 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "4.4.153";
  src = fetchTarball {
    name = "msm-4.4-7083.tar";
    url = https://s3.amazonaws.com/cheryl-factory-images/msm-4.4-7083.tar;
    sha256 = "1s12fclrx1xgjjs4b5vmkj4nbq8hr05xfhp984dia79j6rysvq0m";
  };

  setSourceRoot = ''
    export sourceRoot="$(echo */msm-4.4)"
  '';

  patches = [
    ./0001-mobile-nixos-Adds-and-sets-BGRA-as-default.patch
    ./0001-mobile-nixos-Workaround-selected-processor-does-not-.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  isModular = false;
}).overrideAttrs({ postInstall ? "", postPatch ? "", nativeBuildInputs, ... }: {
  installTargets = [ "zinstall" "Image.gz-dtb" "install" ];
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
