{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../../systems/nixos/network.nix
  ];

  networking.hostName = "phoenix";

  boot.kernelPackages = pkgs.linuxPackages_6_9;

  # Display settings
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # System available packages
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # Do not touch
  system.stateVersion = "24.05";
}
