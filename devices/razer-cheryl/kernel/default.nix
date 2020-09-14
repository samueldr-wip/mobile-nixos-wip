{
  mobile-nixos
, kernelPatches ? [] # FIXME
, buildPackages
, dtbTool
}:

(mobile-nixos.kernel-builder-gcc6 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "4.4-7083";
  src = fetchTarball {
    name = "msm-4.4-7083.tar";
    url = https://s3.amazonaws.com/cheryl-factory-images/msm-4.4-7083.tar;
    sha256 = "1s12fclrx1xgjjs4b5vmkj4nbq8hr05xfhp984dia79j6rysvq0m";
  };

  isModular = false;

}).overrideAttrs({ postInstall ? "", postPatch ? "", ... }: {
  installTargets = [ "zinstall" "Image.gz-dtb" "install" ];
  postPatch = postPatch + ''
    cp -v "${./compiler-gcc6.h}" "./include/linux/compiler-gcc6.h"
  '';
  postInstall = postInstall + ''
    mkdir -p "$out/dtbs/"
    cp -v "$buildRoot/arch/arm64/boot/Image.gz-dtb" "$out/"
  '';
})
