{ mobile-nixos
, fetchFromGitHub
, kernelPatches ? []
, dtbTool
, buildPackages
}:
let inherit (buildPackages) dtc; in
(mobile-nixos.kernel-builder-clang {
  version = "4.14.83";
  configfile = ./config.aarch64;
  file = "Image.gz-dtb";
  hasDTB = true;
  src = fetchFromGitHub {
    owner = "davinci-dev";
    repo = "Xiaomi_Kernel_OpenSource";
    rev = "c218005419cfebd4332773623d464588752d7b11";
    sha256 = "1yr6dgjiray6aalrva3h76mk1wladsygpzdd5vbhcy70179mkm9f";
  };
  #patches = [
  #  ./99_framebuffer.patch
  #  ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  #];

  postPatch = ''
    # Remove -Werror from all makefiles
    local i
    local makefiles="$(find . -type f -name Makefile)
    $(find . -type f -name Kbuild)"
    for i in $makefiles; do
      sed -i 's/-Werror-/-W/g' "$i"
      sed -i 's/-Werror//g' "$i"
    done
    echo "Patched out -Werror"
  '';

  makeFlags = [ "DTC_EXT=${dtc}/bin/dtc" ];

  isModular = false;
}).overrideAttrs ({ postInstall ? "", postPatch ? "", ... }: {
  installTargets = [ "Image.gz" "zinstall" "Image.gz-dtb" "install" ];
  postInstall = postInstall + ''
    cp $buildRoot/arch/arm64/boot/Image.gz-dtb $out/
  '';
})
