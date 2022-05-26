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

        NF_TABLES = yes; # FIXME: >= 3.13
        NF_TABLES_INET = yes; # FIXME: >= 3.14
        NFT_REJECT = yes; # FIXME: >= 3.14
        NETFILTER_XTABLES = yes;
        NETFILTER_XT_MATCH_PKTTYPE = yes;
        NFT_COMPAT = yes; # FIXME: >= 3.13
        NETFILTER_XT_CONNMARK = yes;
        NF_SOCKET_IPV4 = yes; # FIXME: >= 4.10
        # NF_CONNTRACK_IPV6 = yes; < 4.19
        NF_DEFRAG_IPV6 = yes;

        NF_TABLES_NETDEV = yes; # FIXME version
        NF_TABLES_IPV4 = yes; # FIXME version
        NF_TABLES_ARP = yes; # FIXME version

        NF_TABLES_IPV6 = yes; # FIXME version

        IP_NF_RAW = yes; # needed for NETFILTER_XT_TARGET_CT
        IP6_NF_RAW = yes; # needed for NETFILTER_XT_TARGET_CT
        NETFILTER_XT_TARGET_CT      = yes; # needed for NF_CONNTRACK_ZONES
        IP_NF_IPTABLES = yes;
        IP6_NF_IPTABLES = yes;
        # For kernelHasRPFilter
        IP_NF_MATCH_RPFILTER = yes;

NFT_REJECT_NETDEV     = yes;
NF_TABLES_BRIDGE      = yes;


#NETFILTER_INGRESS = yes; # FIXME version
#NETFILTER_EGRESS = yes; # FIXME version
#NETFILTER_SKIP_EGRESS = yes; # FIXME version
#NETFILTER_FAMILY_BRIDGE = yes; # FIXME version
#NETFILTER_FAMILY_ARP = yes; # FIXME version
#NF_CONNTRACK_MARK = yes; # FIXME version
#NF_CONNTRACK_SECMARK = yes; # FIXME version
#NF_CONNTRACK_PROCFS = yes; # FIXME version
#NF_CONNTRACK_LABELS = yes; # FIXME version
#NF_CT_PROTO_DCCP = yes; # FIXME version
#NF_CT_PROTO_GRE = yes; # FIXME version
#NF_CT_PROTO_SCTP = yes; # FIXME version
#NF_CT_PROTO_UDPLITE = yes; # FIXME version
#NETFILTER_NETLINK_GLUE_CT = yes; # FIXME version
#NF_NAT_REDIRECT = yes; # FIXME version
#NF_NAT_MASQUERADE = yes; # FIXME version
#NETFILTER_XTABLES_COMPAT = yes; # FIXME version


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
