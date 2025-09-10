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

  # Kernel specified at 6.6 for the latest LTS
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Display settings
  services.xserver.enable = true;

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "danny";
    package = pkgs.plex.overrideAttrs (old: rec {
      version = "1.42.1.10060-4e8b05daf";
      src = pkgs.fetchurl {
        url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
        sha256 = "1x4ph6m519y0xj2x153b4svqqsnrvhq9n2cxjl50b9h8dny2v0is";
      };
    });
  };
  networking.firewall.allowedTCPPorts = [
    32400
    1900
    5353
    8324
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
