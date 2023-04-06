{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, ...
}:

mobile-nixos.kernel-builder {
  version = "6.2.0";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "m-weigand";
    repo = "linux";
    rev = "76962e58a126c4759be070c41c1955f540afd7fa"; # pinenote_6-2_v3
    hash = "sha256-Sq4uPXKJX9KdZ2P6JXl/Vu6DPY3h8GsUEpE5BpGFr2s=";
  };

  patches = [
    ./0001-HACK-don-t-reflect-EBC-output.patch
    ./0001-mfd-rk808-Fix-power-key-polarity.patch
  ];

  postInstall = ''
    echo ":: Installing selected DTBs"
    # The DTB install copied a bunch of DTBs, we don't need them
    rm -rf $out/dtbs
    mkdir -p $out/dtbs/rockchip
    cp -t "$out/dtbs/rockchip/" -v "$buildRoot/arch/arm64/boot/dts/rockchip"/rk3566-pinenote*.dtb
    # Keeps the build compatible with previous platform firmware builds, though assumes the latter dev batch.
    cp -v "$buildRoot/arch/arm64/boot/dts/rockchip/rk3566-pinenote-v1.2.dtb" "$out/dtbs/rockchip/rk3566-pinenote.dtb"
  '';

  isModular = false;
  isCompressed = false;
}
