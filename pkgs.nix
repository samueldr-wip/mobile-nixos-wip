let
  sha256 = "sha256:1aznlrpins0j5cjmwzizcqiy38apkpv0hq5v5fb0d7r0vfzr2kn5";
  rev = "5ed481943351e9fd354aeb557679624224de38d5";
in
builtins.trace "(Using pinned Nixpkgs at ${rev})"
import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  inherit sha256;
})
