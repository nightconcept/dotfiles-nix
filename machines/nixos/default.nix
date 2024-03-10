{ config, pkgs, inputs, ... }:

{
  # Bootloader
  # boot = {
  #   cleanTmpDir = true;
  #   loader = {
  #   systemd-boot.enable = true;
  #   systemd-boot.editor = false;
  #   efi.canTouchEfiVariables = true;
  #   timeout = 0;
  #   };
  # };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };
  
}