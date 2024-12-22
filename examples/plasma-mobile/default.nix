# Ensure CLI passes down arguments
{ ... }@args:

import ../../support/nix/shared-entry-point.nix (args // {
  configuration = [ (import ./configuration.nix) ];
  additionalHelpInstructions = { device }: ''
    You can build the `-A outputs.default` attribute to build the default output
    for your device.

     $ nix-build examples/plasma-mobile --argstr device ${device} -A outputs.default
  '';
})
