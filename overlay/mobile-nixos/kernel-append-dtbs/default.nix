{ lib, runCommandNoCC }:

let
  inherit (lib)
    escapeShellArgs
  ;
in

{ kernel
/** List of dtb files to append; relative paths are relative to kernel derivation */
, dtbs
}:

runCommandNoCC "${kernel.name}-with-dtbs" {
  passthru = kernel.passthru;
} ''
  PS4=" $ "
  mkdir $out
  (
  cd $out
  for f in ${kernel}/*; do
    ln -s "$f"
  done
  )
  (
  set -x
  # cd so relative paths work implicitly.
  cd ${kernel}
  rm $out/${kernel.file}
  cat ${kernel.file} ${escapeShellArgs dtbs} > $out/${kernel.file}
  )
''
