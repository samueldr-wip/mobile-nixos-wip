{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    (lib.mkIf (config.sound.enable || config.services.pipewire.enable) {
      environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })

    # Pulseaudio
    (lib.mkIf (config.hardware.pulseaudio.enable && !config.hardware.pulseaudio.systemWide) {
      systemd.user.services.pulseaudio.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
    (lib.mkIf (config.hardware.pulseaudio.enable && config.hardware.pulseaudio.systemWide) {
      systemd.services.pulseaudio.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })

    # Pipewire
    (lib.mkIf (config.services.pipewire.enable && !config.services.pipewire.systemWide) {
      systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
    (lib.mkIf (config.services.pipewire.pulse.enable && !config.services.pipewire.systemWide) {
      systemd.user.services.pipewire-pulse.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
    (lib.mkIf (config.services.pipewire.wireplumber.enable && !config.services.pipewire.systemWide) {
      systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })

    (lib.mkIf (config.services.pipewire.enable && config.services.pipewire.systemWide) {
      systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
    (lib.mkIf (config.services.pipewire.pulse.enable && config.services.pipewire.systemWide) {
      systemd.services.pipewire-pulse.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
    (lib.mkIf (config.services.pipewire.wireplumber.enable && config.services.pipewire.systemWide) {
      systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 = "${pkgs.pine64-alsa-ucm}";
    })
  ];
}
