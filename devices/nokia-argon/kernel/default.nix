{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder {
  version = "6.1.0";
  configfile = ./config.armv7;

  src = fetchFromGitHub {
    owner = "msm8916-mainline";
    repo = "linux";
    rev = "refs/tags/v6.1-msm8916";
    sha256 = "sha256-mdtFW6B0mC2XS9UuYqD+5u+mix+zWCVWX8UFBp4/EH4=";
  };

  isModular = false;
  isCompressed = false;
}
