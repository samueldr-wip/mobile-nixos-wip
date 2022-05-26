{ config, lib, options, pkgs, ... }:

let
  inherit (lib)
    mkOption
    types
  ;
in
{
  options = {
    mobile = {
      kernel = {
        structuredConfig = mkOption {
          type = with types; listOf (functionTo attrs);
          description = ''
            Functions returning kernel structured config.

            The functions take one argument, an attrset of helpers.
            These helpers are expected to be used with `with`, they
            provide the `yes`, `no`, `whenOlder` and similar helpers
            from `lib.kernel`.

            The `whenHelpers` are configured with the appropriate
            version already.
          '';
        };
      };
    };
  };

  config = {
    mobile.kernel.structuredConfig = [
      # Basic universal options
      (helpers: with helpers; {
        # POSIX_ACL and XATTR are generally needed.
        TMPFS_POSIX_ACL = yes;
        TMPFS_XATTR = yes;

        # Executive decision that EXT4 is required.
        EXT4_FS = yes;
        EXT4_FS_POSIX_ACL = yes;

        # Additional options
        SYSVIPC = yes;

        # Options from Android kernels that break stuff
        # While not *universally available*, it's universally required to
        # be turned off.
        ANDROID_PARANOID_NETWORK = no;
      })
      # Needed for systemd
      (helpers: with helpers; {
        # Kernel configuration as required by systemd
        # As of https://github.com/systemd/systemd/blob/4917c15af7c2dfe553b8e0dbf22b4fb7cec958de/README#L35
        DEVTMPFS = yes;
        CGROUPS = yes;
        INOTIFY_USER = yes;
        SIGNALFD = yes;
        TIMERFD = yes;
        EPOLL = yes;
        NET = yes;
        UNIX = yes;
        SYSFS = yes;
        PROC_FS = yes;
        FHANDLE = yes;
        CRYPTO_USER_API_HASH = yes;
        CRYPTO_HMAC = yes;
        CRYPTO_SHA256 = yes;
        SYSFS_DEPRECATED = no;
        UEVENT_HELPER_PATH = freeform ''""'';
        FW_LOADER_USER_HELPER = option no;
        BLK_DEV_BSG = yes;
        DEVPTS_MULTIPLE_INSTANCES = whenOlder "4.7" yes;
      })
      # Needed for NixOS features
      (helpers: with helpers; {
        # Firewall
        # needed for nftables
        # Networking Options
        NETFILTER                   = yes;
        NETFILTER_ADVANCED          = yes;
        NF_CONNTRACK                = yes;
        # Core Netfilter Configuration
        NF_CONNTRACK_ZONES          = yes;
        NF_CONNTRACK_EVENTS         = yes;
        NF_CONNTRACK_TIMEOUT        = yes;
        NF_CONNTRACK_TIMESTAMP      = yes;
        # FIXME: >= 4.4
        # NETFILTER_NETLINK_GLUE_CT   = yes;

        IP_NF_RAW = yes; # needed for NETFILTER_XT_TARGET_CT
        IP6_NF_RAW = yes; # needed for NETFILTER_XT_TARGET_CT
        NETFILTER_XT_TARGET_CT      = yes; # needed for NF_CONNTRACK_ZONES
        IP_NF_IPTABLES = yes;
        IP6_NF_IPTABLES = yes;
        # For kernelHasRPFilter
        IP_NF_MATCH_RPFILTER = yes;

        # Required config for Nix
        NAMESPACES = yes;
        USER_NS = yes;
        PID_NS = yes;
      })
    ];

    nixpkgs.overlays = [(final: super: {
      systemBuild-structuredConfig = version:
        let
          helpers = lib.kernel // (lib.kernel.whenHelpers version);
          structuredConfig = 
            lib.mkMerge
              (map (fn: fn helpers) config.mobile.kernel.structuredConfig)
          ;
        in
          structuredConfig
      ;
    })];
  };
}
