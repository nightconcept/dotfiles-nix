{ config, pkgs, inputs, ... }:

{
  # Bootloader
  boot = {
    cleanTmpDir = true;
    loader = {
    systemd-boot.enable = true;
    systemd-boot.editor = false;
    efi.canTouchEfiVariables = true;
    timeout = 0;
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };