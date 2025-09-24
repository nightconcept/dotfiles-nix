# Barrett - VPN torrent server
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  sources = import ./npins;
  pinnedPkgs = import sources.nixpkgs {
    system = builtins.currentSystem;
    config = { allowUnfree = true; };
  };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use pinned nixpkgs
  nixpkgs.pkgs = pinnedPkgs;

  # Networking
  modules.nixos.networking.base.hostName = "barrett";

  # Override bootloader for legacy BIOS (no EFI partition)
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";  # Install GRUB to MBR
    };
  };

  modules.nixos = {
    kernel.type = "lts";

    network = {
      networkManager = true;
      mdns = true;
    };

    # Mount titan network drive for downloads
    network-drives.titan = {
      enable = true;
      # Reference the SOPS secret path
      credentialsFile = config.sops.secrets."network/titan_credentials".path;
    };

    services.vpn-torrent = {
      enable = true;
      user = "danny";
      downloadDir = "/mnt/titan/downloads";  # Use titan network drive
      configDir = "/var/lib/vpn-torrent";    # Local configuration

      qbittorrent = {
        enable = true;
        webUIPort = 8112;
        torrentPort = 6881;
        username = "danny";
        passwordFile = config.sops.secrets."vpn/qbittorrent_password".path;
        passwordHashFile = config.sops.secrets."vpn/qbittorrent_password_hash".path;
      };

      autoremove = {
        enable = true;
        intervalMinutes = 10;  # Run every 10 minutes as requested
        strategies = {
          # Remove torrents after just 10 minutes of seeding
          minimal_seed_strategy = {
            remove = "seeding_time > 600";  # 600 seconds = 10 minutes
            delete_data = true;
          };
        };
      };

      nordvpn = {
        enable = true;
        # Use the actual path where SOPS deploys the secret
        tokenFile = config.sops.secrets."vpn/nordvpn_token".path;
        country = "United States";  # P2P servers are available in most US locations
      };
    };
  };


  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "24.11";
}