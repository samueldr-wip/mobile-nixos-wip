# What's release.nix?
# ===================
#
# This is mainly intended to be run by the build farm at the foundation's Hydra
# instance. Though you can use it to run your builds, it is not as ergonomic as
# using `nix-build` on `./default.nix`.
#
# Also note that *by design* it still relies on NIX_PATH being used for the
# input Nixpkgs.
#
# Note:
# Verify that .ci/instantiate-all.nix lists the expected paths when adding to this file.

{ mobile-nixos ? builtins.fetchGit ./.

# By default, builds all devices.
, devices ? null

# By default, assume we eval only for this eval's system
, systems ? null

# Some additional configuration will be made with this.
# Mainly to work with some limitations (output size).
, inNixOSHydra ? false

# Takes a lot of RAM to evaluate `tested` and `testedPlus`.
, fullRelease ? false

# The current system, for pure evals it must be provided.
, system ? null

# The Nixpkgs this release is evaluated with.
# By default relies on the pinned Nixpkgs.
, pkgs ? null

# This parameter allows the tooling to ask for the “internal” representation
# of the release jobset CI information. In turn, this can be used to extract
# a bit more information, which does not make sense for nix-build.
, evalForCI ? false

# When dryRun is true, the evaluation does not attempt to produce
# derivations, it only makes the structure of the attrs.
# This allows verifying that the evaluation for the attrset structure
# of the release file is cheap, and also makes it possible to introspect
# the release for attribute-per-attribute instantiating.
, dryRun ? false
}@args':

# Additional arguments handling.
let
  mobileReleaseTools = (import ./lib/release-tools.nix { inherit pkgs; });

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
    else (import ./pkgs.nix { inherit system; })
  ;

  systems =
    if args' ? systems
    then args'.systems
    else [ system ];

  devices =
    if args' ? devices && args'.devices != null
    then args'.devices
    else mobileReleaseTools.all-devices
  ;

  inherit (pkgs.lib)
    filterAttrs
    filterAttrsRecursive
    genAttrs
    getAttrFromPath
    isDerivation
    isList
    mapAttrsRecursive
    optionalAttrs
    unique
  ;

  inherit (mobileReleaseTools)
    readOverlayAttributeNames
    recurseIntoPackageSet
  ;

  inherit (mobileReleaseTools.withPkgs pkgs)
    evalFor
    evalWithConfiguration
    specialConfig
  ;

  # Systems we should eval for, per host system.
  # Non-native will be assumed cross.
  fromLocalSystemToCrossTargets =
    {
      x86_64-linux = [
        "armv7l-linux"
        "aarch64-linux"
        "x86_64-linux"
      ];
      aarch64-linux = [
        "aarch64-linux"
      ];
      armv7l-linux = [
        "armv7l-linux"
      ];
    }
  ;

  # For a given system, return systems on which it could be compiled from.
  # In other words, given a system in this attrset, list all systems it should be evaluated on.
  fromTargetToSystems =
    builtins.listToAttrs
    (
      builtins.map
      (
        system:

        {
          name = system;
          value =
            builtins.filter
            (name: (builtins.elem system fromLocalSystemToCrossTargets.${name}))
            (builtins.attrNames fromLocalSystemToCrossTargets)
          ;
        }
      )
      (unique (builtins.concatLists (builtins.attrValues fromLocalSystemToCrossTargets)))
    )
  ;

  # An attrset of `$device = $system;` entries.
  # This is used to build the cross/non-cross matrices
  # Cost for evaluating this
  deviceSystems =
    genAttrs devices (
      device: (evalWithConfiguration {} device).config.mobile.system.system
    )
  ;

  releaseConfigs = {
    "unconfigured" = {};
    "hello" = {
      configuration = {
        imports = [
          ./examples/hello/configuration.nix
        ];
      };
    };
    "installer" = {
      configuration = {
        imports = [
          ./examples/installer/configuration.nix
        ];
      };
    };
    "phosh" = {
      configuration = {
        imports = [
          ./examples/phosh/configuration.nix
        ];
      };
      evalForCross = false;
    };
    "plasma-mobile" = {
      configuration = {
        imports = [
          ./examples/plasma-mobile/configuration.nix
        ];
      };
      evalForCross = false;
    };
  };

  evalAllConfigs =
    { device, system, dryRun, releaseConfigs }:
    genAttrs (builtins.attrNames releaseConfigs)
    (
      name:
      with (
        {
          inherit name;
          configuration = {};
        } // releaseConfigs.${name}
      );
      let
        eval = evalWithConfiguration configuration device;
      in
      if dryRun
      then "<unrealized eval for ${device} ${name}>"
      else {
        inherit (eval.config.mobile.outputs) default initrd toplevel;
        kernel = eval.config.mobile.boot.stage-1.kernel.package;
      }
    )
  ;

  evalDeviceForSystem =
    { system, device, dryRun }:

    let
      crossReleaseConfigs = filterAttrs (name: value: value.evalForCross or true) releaseConfigs;
    in
    {
      cross = genAttrs (builtins.filter (el: el != system) (fromTargetToSystems.${system})) (
        localSystem:
        evalAllConfigs { inherit device dryRun; system = localSystem; releaseConfigs = crossReleaseConfigs; }
      );
    } // (optionalAttrs (builtins.elem system systems) {
      native = evalAllConfigs { inherit device system dryRun releaseConfigs; };
    })
  ;

  overlayJobs =
    let
      # A cheap evaluation of (most) of the shape of our overlay.
      # It will be missing `recurseForDerivations` attrsets from `callPackage` invocations.
      # Though that's not an issue, since those will be found when evaluating.
      overlayAttrs =
        readOverlayAttributeNames
        (
          bogusPkgs:
          # Workarounds for inter-dependencies...
          # TODO: find cursed Nix usage to remove this?
          {
            image-builder = false;
            mobile-nixos = bogusPkgs // {
              stage-1 = bogusPkgs // {
                boot-recovery-menu = bogusPkgs // {
                  simulator = bogusPkgs.__tarpit;
                };
                boot-splash = bogusPkgs // {
                  simulator = bogusPkgs.__tarpit;
                };
              };
            };
          }
        )
        (import ./overlay/overlay.nix)
      ;

      # Extract the overlayAttrs shape from the "full" `pkgs` from a the given evaluation.
      evalOverlay =
        { eval }:
        mapAttrsRecursive
        (path: value:
        let
          drv = getAttrFromPath value eval.pkgs;
        in
          if !(isList value) then value else
          if (isDerivation drv)
          then (
            if dryRun
            then "<unrealized eval for overlay entry ${builtins.concatStringsSep "." value}>"
            else drv
          )
          else null
        )
        (
          filterAttrsRecursive
          (path: value: value != null)
          (recurseIntoPackageSet { packageset = overlayAttrs; inherit eval; })
        )
      ;
    in
    (
      genAttrs (systems) (
        system:
        let
          evals =
            builtins.listToAttrs (
              builtins.map (
                name:
                rec {
                  inherit name;
                  value = evalFor (specialConfig {
                    inherit name system;
                    buildingForSystem = name;
                  });
                }
              ) fromLocalSystemToCrossTargets.${system})
          ;
          crossSystems =
            builtins.filter
            (el: el != system)
            fromLocalSystemToCrossTargets.${system}
          ;
        in
        ({
        }) // (optionalAttrs (crossSystems != []) {
          cross = genAttrs crossSystems (
            crossSystem:
            (evalOverlay { eval = evals.${crossSystem}; })
          );
        }) // (optionalAttrs (builtins.elem system systems) {
          native =
            (evalOverlay { eval = evals.${system}; })
          ;
        })
      )
    )
  ;

  # This attribute set contains the jobs (the only thing exposed by default)
  # and additional metadata / configuration that the CI infrastructure can use.
  CI = {
    _data = {
      inherit
        fromLocalSystemToCrossTargets
        fromTargetToSystems
        deviceSystems
      ;
# XXX we now have access to arm64 runners :o
##### XXX #####      buildInCI = [
##### XXX #####        # This list of paths is used by the CI over on github to create
##### XXX #####        # a matrix of packages to build.
##### XXX #####        [ "devices" "pine64-pinephone" "unconfigured" "x86_64-linux" "hello" ]
##### XXX #####        [ "devices" "pine64-pinephonePro" "unconfigured" "x86_64-linux" "hello" ]
##### XXX #####        [ "devices" "pine64-pinephone" "cross" "x86_64-linux" "hello" ]
##### XXX #####        [ "devices" "pine64-pinephonePro" "cross" "x86_64-linux" "hello" ]
##### XXX #####      ];
    };


    # XXX
    jobs = {
      overlay = overlayJobs;
      devices =
        genAttrs devices (
          device:
          let
            system = (evalWithConfiguration {} device).config.mobile.system.system;
          in
          evalDeviceForSystem {
            inherit dryRun;
            inherit system device;
          }
        )
      ;
    };
  };
in

if evalForCI
then CI
else CI.jobs
