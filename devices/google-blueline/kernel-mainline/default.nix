{ mobile-nixos
, fetchFromGitHub
, fetchFromGitLab
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "5.19.0";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "20795113b74df511fd599d3867a6bd1a5b0f9c48"; # XXX caleb/pixel3-bringup-5.19 DO NOT SHIP
    hash = "sha256-rPvDe+xgClToIvKKbhC1y/fxeZnD+carx8zYy5KdsJ0=";
  };

  patches = [
    # Present in sd845-mainline WIP bringup branch already
    # ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
  ];

  # TODO: generic mainline build; append per-device...
  postInstall = ''
    echo ':: Copying kernel'
    (PS4=" $ "; set -x
    cp -v \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $out/
    )
    echo ':: Appending DTB'
    (PS4=" $ "; set -x
    cat \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $buildRoot/arch/arm64/boot/dts/qcom/sdm845-google-blueline.dtb \
      > $out/Image.${isCompressed}-dtb
    )
  '';

  isModular = false;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
}
