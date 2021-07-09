{ config, lib, pkgs, ... }:

let
  inherit (lib) mkForce;
  system_type = config.mobile.system.type;

  # Why copy them all?
  # Because otherwise the wallpaper picker will default to /nix/store as a path
  # and this could get messy with the amazing amount of files there are in there.
  # Why copy only pngs?
  # Rendering of `svg` is hard! Not that it's costly in cpu time, but that the
  # rendering might not be as expected depending on what renders it.
  # The SVGs in that directory are used as an authoring format files, not files
  # to be used as they are. They need to be pre-rendered.
  wallpapers = pkgs.runCommandNoCC "wallpapers" {} ''
    mkdir -p $out/
    cp ${../../artwork/wallpapers}/*.png $out/
  '';
in
{
  imports = [
    ./workaround-v4l_id-hang.nix
  ];

  config = lib.mkMerge [
    {

      boot.growPartition = lib.mkDefault true;

      services.xserver = {
        enable = true;

        libinput.enable = true;
        videoDrivers = lib.mkDefault [
          # Try modesetting first
          "modesetting"
          # Fallback on fbdev (for many android vendor kernels)
          "fbdev"
        ];

        # Automatically login as nixos.
        displayManager.lightdm = {
          enable = true;
          greeters.gtk.extraConfig = ''
            [greeter]
            keyboard=${pkgs.onboard}/bin/onboard
          '';
        };
        displayManager.autoLogin = {
          enable = true;
          user = "nixos";
        };

      };

      # Ensures this demo rootfs is useable for platforms requiring FBIOPAN_DISPLAY.
      mobile.quirks.fb-refresher.enable = true;

      powerManagement.enable = true;
      hardware.pulseaudio.enable = true;

      environment.systemPackages = with pkgs; [
        lightlocker
        dtc
        file
        (writeShellScriptBin "firefox" ''
          export MOZ_USE_XINPUT2=1
          exec ${pkgs.firefox}/bin/firefox "$@"
        '')
        sgtpuzzles

        # Shim for light-locker
        (writeShellScriptBin "xfce4-screensaver-command" ''
          exec ${lightlocker}/bin/light-locker-command "$@"
        '')
      ];

      # Hacky way to setup an initial brightness
      # TODO: better factor this out...
      mobile.boot.stage-1.initFramebuffer = ''
        brightness=10
        echo "Setting brightness to $brightness"
        if [ -e /sys/class/backlight/backlight/brightness ]; then
          echo $(($(cat /sys/class/backlight/backlight/max_brightness) * brightness / 100)) > /sys/class/backlight/backlight/brightness
        elif [ -e /sys/class/leds/lcd-backlight/max_brightness ]; then
          echo $(($(cat /sys/class/leds/lcd-backlight/max_brightness)  * brightness / 100)) > /sys/class/leds/lcd-backlight/brightness
        elif [ -e /sys/class/leds/lcd-backlight/brightness ]; then
          # Assumes max brightness is 100... probably wrong, but good enough, eh.
          echo $brightness > /sys/class/leds/lcd-backlight/brightness
        fi
      '';

      # Puts some icons on the desktop.
      system.activationScripts.fillDesktop = let
        minesDesktopFile = pkgs.writeScript "mines.desktop" ''
          [Desktop Entry]
          Version=1.0
          Type=Application
          Name=Mines
          Exec=${pkgs.sgtpuzzles}/bin/sgt-puzzle-mines
        '';

        homeDir = "/home/nixos/";
        desktopDir = homeDir + "Desktop/";

      in ''
        mkdir -p ${desktopDir}
        chown nixos ${homeDir} ${desktopDir}

        ln -sfT ${minesDesktopFile} ${desktopDir + "mines.desktop"}
      '';

      users.users.nixos = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" ];
      };
    }

    {
      # Forcibly set a password on users...
      # FIXME: highly insecure!
      # FIXME: Figure out why this breaks...
      #services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.users.nixos.password = "nixos";
      users.users.root.password = "nixos";
    }

    # Networking, modem and misc.
    {
      users.extraUsers.nixos.extraGroups = [ "dialout" ];
      networking.wireless.enable = false;
      # FIXME : Stop relying on initrd for `ssh` via USB.
      networking.networkmanager.enable = true;
      networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];

      # Setup USB gadget networking in initrd...
      mobile.boot.stage-1.networking.enable = lib.mkDefault true;
    }

    # Bluetooth
    {
      services.blueman.enable = true;
      hardware.bluetooth.enable = true;
    }

    # SSH
    {
      # Start SSH by default...
      systemd.services.sshd.wantedBy = lib.mkOverride 10 [ "multi-user.target" ];
      services.openssh.permitRootLogin = lib.mkForce "yes";

      # Don't start it in stage-1 though.
      # (Currently doesn't quit on switch root)
      #mobile.boot.stage-1.ssh.enable = true;
    }

    # Customized XFCE environment
    {
      services.xserver = {
        desktopManager.xfce.enable = true;
      };

      environment.systemPackages = with pkgs; [
        adapta-gtk-theme
        breeze-icons
      ];

      fonts.fonts = with pkgs; [
        aileron
      ];

      environment.etc."xdg/xfce4" = {
        # TODO: DPI/size settings, so that a DPI can be derived from the device info.
        source =  pkgs.runCommandNoCC "xfce4-defaults" {} ''
          cp -r ${./xdg/xfce4} $out
          wallpaper="${wallpapers}/mobile-nixos-19.09.png"
          substituteInPlace $out/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
            --subst-var wallpaper
        '';
      };
    }

    # Replace xfwm with awesome with a custom config.
    {
      services.xserver = {
        desktopManager.xfce.enableXfwm = false;
        displayManager.sessionCommands = ''
          awesome &
        '';
      };

      environment.systemPackages = with pkgs;
      let
        close = writeShellScript "action-close-window" ''
          awesome-client '
            local awful = require("awful");
            local c = awful.client.focus.filter(client.focus)
            if c then
              c:kill()
            end
          '
        '';
      in
      [
        awesome
        (runCommandNoCC "awesome-actions" {} ''
          mkdir -vp $out/share/applications/
          (cd $out/share/applications/
          cat > awesome-close.desktop <<EOF
          [Desktop Entry]
          Name=Close active window
          Exec=${close}
          Icon=process-stop
          EOF
          )
        ''/* TODO: better icon than process-stop */)
      ];

      environment.etc."xdg/awesome" = {
        source = ./xdg/awesome;
      };

      services.unclutter.enable = true;
    }

    # Onboard on-screen keyboard
    {
      environment.systemPackages = with pkgs; [
        onboard
      ];
      environment.etc."xdg/autostart/onboard-boottime-configuration.desktop" = {
        text = let script = pkgs.writeShellScript "onboard-boottime-configuration" ''
          set -u
          set -e

          # A bit rude, but this ensures the keyboard always starts at a quarter
          # of the resolution.
          # onboard will not accept -s to set size with a docked keyboard.
          height=$(( $( ${pkgs.xlibs.xwininfo}/bin/xwininfo -root | grep '^\s\+Height:' | cut -d':' -f2 ) / 4 ))

          ${pkgs.gnome3.dconf}/bin/dconf write /org/onboard/window/landscape/dock-height "$height" || :
          ${pkgs.gnome3.dconf}/bin/dconf write /org/onboard/window/portrait/dock-height "$height"  || :
        '';
        in ''
          [Desktop Entry]
          Name=Onboard boot time configuration
          Exec=${script}
          X-XFCE-Autostart-Override=true
        '';
      };
      environment.etc."xdg/autostart/onboard-autostart.desktop" = {
        source = pkgs.runCommandNoCC "onboard-autostart.desktop" {} ''
          cat "${pkgs.onboard}/etc/xdg/autostart/onboard-autostart.desktop" > $out
          echo "X-XFCE-Autostart-Override=true" >> $out
          substituteInPlace $out \
            --replace "Icon=onboard" "Icon=input-keyboard"
        '';
      };
    }

    {
      # Force userdata for the target partition. It is assumed it will not
      # fit in the `system` partition.
      mobile.system.android.system_partition_destination = "userdata";
    }
  ];
}
