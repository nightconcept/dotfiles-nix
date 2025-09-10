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
    32400
    1900
    5353
    7359
    8096
    8324
    32410
    32412
    32413
    32414
    32469
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # System available packages
  environment.systemPackages = with pkgs; [
    home-manager
    podman-compose
    lazydocker
  ];

  # Shell aliases for podman compatibility
  programs.bash.shellAliases = {
    lazydocker = "DOCKER_HOST=unix:///run/user/1000/podman/podman.sock lazydocker";
  };
  programs.zsh.shellAliases = {
    lazydocker = "DOCKER_HOST=unix:///run/user/1000/podman/podman.sock lazydocker";
  };

  # Systemd service for Jellyfin container
  systemd.services.jellyfin-container = {
    description = "Jellyfin Media Server (Podman)";
    after = [ "network-online.target" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "danny";
      Group = "users";
      WorkingDirectory = "/home/danny/git/homelab-containers/jellyfin";
      ExecStartPre = "${pkgs.podman-compose}/bin/podman-compose down";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
      Restart = "on-failure";
      RestartSec = "30s";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Do not touch
  system.stateVersion = "23.11";
}
