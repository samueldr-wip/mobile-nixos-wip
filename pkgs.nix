let
  sha256 = "sha256:0ikm5ch8vnpkc63cw56nkhkrxikxy3dj42029wjshwy375jgldq6";
  rev = "b784c5ae63dd288375af1b4d37b8a27dd8061887";
in
builtins.trace "(Using pinned Nixpkgs at ${rev})"
import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  inherit sha256;
})
