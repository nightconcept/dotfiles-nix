{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.modules.nixos.services.vpn-torrent;

  # Import our custom lib functions
  moduleLib = import ../../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt mkOpt enabled disabled;
in
{
  options.modules.nixos.services.vpn-torrent = {
    enable = mkBoolOpt false "Enable VPN-protected torrent service with NordVPN and qBittorrent";

    user = mkOpt lib.types.str "danny" "User to run qBittorrent service as";

    downloadDir = mkOpt lib.types.str "/mnt/titan/downloads" "Directory for downloads";

    configDir = mkOpt lib.types.str "/var/lib/vpn-torrent" "Directory for qBittorrent configuration";

    qbittorrent = {
      enable = mkBoolOpt true "Enable qBittorrent service";
      webUIPort = mkOpt lib.types.port 8080 "Port for qBittorrent Web UI";
      torrentPort = mkOpt lib.types.port 6881 "Port for BitTorrent traffic";
      openFirewall = mkBoolOpt true "Open firewall ports for qBittorrent";
    };

    nordvpn = {
      enable = mkBoolOpt true "Enable NordVPN service using wgnord";
      tokenFile = mkOpt lib.types.nullOr lib.types.path null "Path to NordVPN token file (managed via SOPS)";
      # Note: wgnord doesn't support P2P server selection directly, so we use country-based selection
      # P2P servers are available in most countries and NordVPN automatically routes P2P traffic
      country = mkOpt lib.types.str "United States" "NordVPN server country (P2P servers available in most locations)";
      autoConnect = mkBoolOpt true "Automatically connect to VPN on boot";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common configuration
    {
      # Create required directories for configuration
      systemd.tmpfiles.rules = [
        "d ${cfg.configDir} 0755 ${cfg.user} ${cfg.user} -"
        "d ${cfg.configDir}/qbittorrent 0755 ${cfg.user} ${cfg.user} -"
        "d /var/lib/wgnord 0755 root root -"
      ];

      # Note: Download directory creation is handled by the network-drives module
      # or should exist if using local storage
    }

    # qBittorrent configuration
    (mkIf cfg.qbittorrent.enable {
      # qBittorrent-nox service (headless with web UI)
      systemd.services.qbittorrent = {
        description = "qBittorrent-nox service";
        after = [ "network.target" "mnt-titan.mount" ] ++ lib.optional cfg.nordvpn.enable "wgnord.service";
        wants = lib.optional cfg.nordvpn.enable "wgnord.service";
        requires = [ "mnt-titan.mount" ];  # Ensure titan mount is available
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.user;

          # Configure qBittorrent with download directory and profile location
          ExecStart = ''
            ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
              --webui-port=${toString cfg.qbittorrent.webUIPort} \
              --profile=${cfg.configDir}/qbittorrent \
              --save-path=${cfg.downloadDir}
          '';

          Restart = "on-failure";
          RestartSec = "10s";

          # Security hardening
          PrivateTmp = true;
          ProtectSystem = "strict";
          ReadWritePaths = [
            cfg.configDir
            cfg.downloadDir
            "/mnt/titan"  # Ensure access to titan mount
          ];
          NoNewPrivileges = true;

          # Ensure qBittorrent runs only when VPN is active
          BindsTo = lib.optional cfg.nordvpn.enable "wgnord.service";
        };
      };

      # Firewall rules for qBittorrent
      networking.firewall = mkIf cfg.qbittorrent.openFirewall {
        allowedTCPPorts = [
          cfg.qbittorrent.webUIPort
          cfg.qbittorrent.torrentPort
        ];
        allowedUDPPorts = [
          cfg.qbittorrent.torrentPort
        ];
      };

      # Install qBittorrent package
      environment.systemPackages = with pkgs; [
        qbittorrent-nox
      ];
    })

    # NordVPN configuration using wgnord
    (mkIf cfg.nordvpn.enable {
      # wgnord service for NordVPN WireGuard connection
      # Note: NordVPN automatically routes P2P traffic through appropriate servers
      # even when connected to regular servers in P2P-supported countries
      systemd.services.wgnord = {
        description = "NordVPN WireGuard (wgnord) service - P2P optimized";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          # Login with token if token file is provided
          ${lib.optionalString (cfg.nordvpn.tokenFile != null) ''
            if [ -f "${cfg.nordvpn.tokenFile}" ]; then
              TOKEN=$(cat "${cfg.nordvpn.tokenFile}")
              ${pkgs.wgnord}/bin/wgnord l "$TOKEN"
            else
              echo "Warning: NordVPN token file not found at ${cfg.nordvpn.tokenFile}"
              exit 1
            fi
          ''}
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          # Connect to country - NordVPN will handle P2P routing automatically
          ExecStart = "${pkgs.wgnord}/bin/wgnord c \"${cfg.nordvpn.country}\"";
          ExecStop = "${pkgs.wgnord}/bin/wgnord d";
          Restart = "on-failure";
          RestartSec = "30s";

          # Run as root for network configuration
          User = "root";

          # Security
          PrivateTmp = true;
          ProtectHome = true;
        };
      };

      # Install wgnord and dependencies
      environment.systemPackages = with pkgs; [
        wgnord
        wireguard-tools
        openresolv  # Required for DNS management
      ];

      # Enable WireGuard kernel module
      boot.kernelModules = [ "wireguard" ];

      # Enable IP forwarding for VPN
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      # Configure wgnord template
      environment.etc."wgnord/template.conf" = {
        text = ''
          [Interface]
          PrivateKey = <privatekey>
          Address = <address>
          DNS = 103.86.96.100,103.86.99.100
          MTU = 1420

          [Peer]
          PublicKey = <publickey>
          AllowedIPs = 0.0.0.0/0, ::/0
          Endpoint = <endpoint>
        '';
      };
    })
  ]);
}