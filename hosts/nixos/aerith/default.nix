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

  networking.hostName = "aerith";

  # Kernel specified at 6.12 for the latest LTS
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Display settings
  services.xserver.enable = true;

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "danny";
  };
  networking.firewall.allowedTCPPorts = [
    5353
    8324
    32400
    32410
    32412
    32413
    32414
    32469
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # System available packages
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
