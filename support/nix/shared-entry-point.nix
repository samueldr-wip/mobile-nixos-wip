#
# Common interface for examples and default build.
# **Not a public interface.**
#
# This file is used to provide the same in-repository arguments parsing for `system`
# and `pkgs`, to be provided to the generic `eval-with-configuration` helper.
#
{ system ? null
, pkgs ? null
, ...
}@args':

#
# Do some arguments parsing.
#
let
  system =
    if args' ? system
    then (args'.system)
    else builtins.currentSystem
  ;
  pkgs =
    if args' ? pkgs
    then
      if args' ? system
      then builtins.throw "Providing the `system` argument when providing your own `pkgs` is forbidden. You should instead pass the desired `system` argument to your `pkgs` instance."
      else (args'.pkgs)
    else (import ../../pkgs.nix { inherit system; })
  ;

  # Inherit default values correctly in `args`
  args = builtins.removeAttrs (args' // {
    inherit pkgs;
  }) [
    "system"
  ];
in

import ../../lib/eval-with-configuration.nix (args)
