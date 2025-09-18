{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) enabled disabled;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "barrett";

  modules.nixos = {
    kernel.type = "lts";

    network = {
      networkManager = true;
      mdns = true;
    };

    # Mount titan network drive for downloads
    network-drives.titan = {
      enable = true;
      # Uses default settings for server, mount point, etc.
    };

    services.vpn-torrent = {
      enable = true;
      user = "danny";
      downloadDir = "/mnt/titan/downloads";  # Use titan network drive
      configDir = "/var/lib/vpn-torrent";    # Local configuration

      qbittorrent = {
        enable = true;
        webUIPort = 8080;
        torrentPort = 6881;
      };

      nordvpn = {
        enable = true;
        # Token managed via SOPS - automatically deployed to this path
        tokenFile = "/run/secrets/nordvpn-token";
        country = "United States";  # P2P servers are available in most US locations
      };
    };
  };

  services.openssh.enable = true;

  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "24.11";
}