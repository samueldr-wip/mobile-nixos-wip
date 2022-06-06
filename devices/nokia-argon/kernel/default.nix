{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder-gcc49 {
  version = "3.10.49";
  configfile = ./config.armv7;

  src = fetchFromGitHub {
    owner = "mobile-nixos";
    repo = "linux";
    rev = "0e0a84ad0cb457c04f7810b86710982cbc5a4629"; # nokia-argon/LF.BR.1.2.9-19300-8x09.0+mobile-nixos
    sha256 = "sha256-ju3ioY+JvLA5QpSMG7rNe8mQvM/dLxHxsfPv8LoNRWo=";
  };

  makeFlags = [
    "TARGET_PRODUCT=argon"
  ];

  isModular = false;
  isQcdt = true;
  qcdt_dtbs = "arch/arm/boot/";

  # Things are seemingly wrong in that kernel build with parallelization...
  enableParallelBuilding = false;
}
