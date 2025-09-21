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
      username = mkOpt lib.types.str "danny" "qBittorrent Web UI username";
      passwordFile = mkOpt (lib.types.nullOr lib.types.path) null "Path to file containing qBittorrent password (from SOPS)";
    };

    autoremove = {
      enable = mkBoolOpt true "Enable autoremove-torrents service";
      intervalMinutes = mkOpt lib.types.int 10 "How often to run autoremove-torrents (in minutes)";
      strategies = mkOpt lib.types.attrs {
        default_strategy = {
          remove = "seeding_time > 604800 or ratio > 2.0"; # Remove after 1 week or 2.0 ratio
          delete_data = true;
        };
      } "Autoremove strategies configuration";
    };

    nordvpn = {
      enable = mkBoolOpt true "Enable NordVPN service using wgnord";
      tokenFile = mkOpt (lib.types.nullOr lib.types.path) null "Path to NordVPN token file (managed via SOPS)";
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
        "d ${cfg.configDir} 0755 ${cfg.user} users -"
        "d ${cfg.configDir}/qbittorrent 0755 ${cfg.user} users -"
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

        preStart = lib.mkIf (cfg.qbittorrent.passwordFile != null) ''
          # Ensure config directory exists
          mkdir -p ${cfg.configDir}/qbittorrent/qBittorrent/config
          mkdir -p ${cfg.configDir}/qbittorrent/qBittorrent/data/logs

          # Generate qBittorrent config with password from SOPS
          if [ -f "${cfg.qbittorrent.passwordFile}" ]; then
            echo "Generating qBittorrent configuration..."

            # Read password from SOPS
            PASSWORD=$(cat "${cfg.qbittorrent.passwordFile}")

            # Generate MD5 hash for HA1 authentication (legacy, kept for compatibility)
            REALM="Web UI Access"
            HASH_MD5=$(echo -n "${cfg.qbittorrent.username}:$REALM:$PASSWORD" | md5sum | cut -d' ' -f1)

            # Generate PBKDF2 hash for secure authentication
            # This is a simplified version - in production you'd use the actual hash from qBittorrent
            # For now, we'll let qBittorrent regenerate this on first login

            cat > ${cfg.configDir}/qbittorrent/qBittorrent/config/qBittorrent.conf << EOF
          [Application]
          FileLogger\\Age=1
          FileLogger\\AgeType=1
          FileLogger\\Backup=true
          FileLogger\\DeleteOld=true
          FileLogger\\Enabled=true
          FileLogger\\MaxSizeBytes=66560
          FileLogger\\Path=${cfg.configDir}/qbittorrent/qBittorrent/data/logs

          [BitTorrent]
          Session\\AddTorrentStopped=false
          Session\\DefaultSavePath=${cfg.downloadDir}
          Session\\ExcludedFileNames=
          Session\\Port=${toString cfg.qbittorrent.torrentPort}
          Session\\QueueingSystemEnabled=true
          Session\\ShareLimitAction=Stop

          [Core]
          AutoDeleteAddedTorrentFile=Never

          [Meta]
          MigrationVersion=8

          [Network]
          Proxy\\HostnameLookupEnabled=false
          Proxy\\Profiles\\BitTorrent=true
          Proxy\\Profiles\\Misc=true
          Proxy\\Profiles\\RSS=true

          [Preferences]
          Connection\\PortRangeMin=${toString cfg.qbittorrent.torrentPort}
          Downloads\\SavePath=${cfg.downloadDir}
          General\\Locale=en
          MailNotification\\req_auth=true
          WebUI\\CSRFProtection=false
          WebUI\\LocalHostAuth=false
          WebUI\\Password_ha1=@ByteArray($HASH_MD5)
          WebUI\\Port=${toString cfg.qbittorrent.webUIPort}
          WebUI\\Username=${cfg.qbittorrent.username}

          [RSS]
          AutoDownloader\\DownloadRepacks=true
          AutoDownloader\\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"
          EOF

            chown ${cfg.user}:users ${cfg.configDir}/qbittorrent/qBittorrent/config/qBittorrent.conf
            chmod 600 ${cfg.configDir}/qbittorrent/qBittorrent/config/qBittorrent.conf

            echo "qBittorrent configuration generated with username: ${cfg.qbittorrent.username}"
          else
            echo "Warning: Password file not found at ${cfg.qbittorrent.passwordFile}"
            echo "qBittorrent will start with a temporary password"
          fi
        '';

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = "users";  # Use the 'users' group instead of username
          PermissionsStartOnly = true;  # Allow preStart to run as root

          # Configure qBittorrent with download directory and profile location
          ExecStart = ''
            ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
              --confirm-legal-notice \
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

    # Autoremove-torrents configuration
    (mkIf cfg.autoremove.enable {
      # Install autoremove-torrents Python package
      environment.systemPackages = with pkgs; [
        (python3.withPackages (ps: with ps; [
          pyyaml
          requests
          # Custom autoremove-torrents package will be defined below
        ]))
      ];

      # Create directories
      systemd.tmpfiles.rules = [
        "d /etc/autoremove-torrents 0755 root root -"
        "d /var/log/autoremove-torrents 0755 ${cfg.user} users -"
      ];

      # Generate config at runtime with the actual password
      systemd.services.autoremove-torrents-config = {
        description = "Generate autoremove-torrents configuration";
        wantedBy = [ "autoremove-torrents.service" ];
        before = [ "autoremove-torrents.service" ];

        script = lib.mkIf (cfg.qbittorrent.passwordFile != null) ''
          # Read password from SOPS
          if [ -f "${cfg.qbittorrent.passwordFile}" ]; then
            PASSWORD=$(cat "${cfg.qbittorrent.passwordFile}")

            cat > /etc/autoremove-torrents/config.yml << EOF
          qbittorrent_task:
            client: qbittorrent
            host: http://127.0.0.1:${toString cfg.qbittorrent.webUIPort}
            username: ${cfg.qbittorrent.username}
            password: "$PASSWORD"
            strategies:
          EOF

            # Add strategies from Nix config
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: strategy: ''
              echo "      ${name}:" >> /etc/autoremove-torrents/config.yml
              echo "        remove: '${strategy.remove}'" >> /etc/autoremove-torrents/config.yml
              echo "        delete_data: ${if strategy.delete_data then "true" else "false"}" >> /etc/autoremove-torrents/config.yml
            '') cfg.autoremove.strategies)}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

      # Autoremove-torrents systemd service
      systemd.services.autoremove-torrents = {
        description = "Remove torrents automatically according to configured strategies";
        after = [ "qbittorrent.service" ];
        wants = [ "qbittorrent.service" ];

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = "users";
          
          # Security hardening
          PrivateTmp = true;
          ProtectSystem = "strict";
          ReadWritePaths = [
            "/var/log/autoremove-torrents"
            "/home/${cfg.user}/.local" # For pip install --user
          ];
          NoNewPrivileges = true;
        };

        script = ''
          # Install autoremove-torrents if not already installed
          ${pkgs.python3.withPackages (ps: with ps; [ pip ])}/bin/pip install --user autoremove-torrents || true

          # Run autoremove-torrents with static config file
          ${pkgs.python3}/bin/python -m autoremove_torrents \
            --conf=/etc/autoremove-torrents/config.yml \
            --log=/var/log/autoremove-torrents
        '';
      };

      # Systemd timer for periodic execution
      systemd.timers.autoremove-torrents = {
        description = "Run autoremove-torrents every ${toString cfg.autoremove.intervalMinutes} minutes";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnBootSec = "${toString cfg.autoremove.intervalMinutes}min";
          OnUnitActiveSec = "${toString cfg.autoremove.intervalMinutes}min";
          Unit = "autoremove-torrents.service";
        };
      };
    })

    # NordVPN configuration using wgnord
    (mkIf cfg.nordvpn.enable {
      # Create necessary directories for wgnord
      systemd.tmpfiles.rules = [
        "d /etc/wireguard 0755 root root -"
        "d /var/lib/wgnord 0755 root root -"
      ];

      # Setup wgnord required files
      system.activationScripts.wgnord-setup = ''
        # Create wgnord data directory
        mkdir -p /var/lib/wgnord

        # Copy template.conf if it doesn't exist
        if [ ! -f /var/lib/wgnord/template.conf ]; then
          cat > /var/lib/wgnord/template.conf << 'EOF'
        [Interface]
        PrivateKey = <privatekey>
        Address = <address>
        DNS = 103.86.96.100,103.86.99.100
        MTU = 1420

        [Peer]
        PublicKey = <publickey>
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = <endpoint>
        EOF
        fi

        # Copy country files from the wgnord package
        if [ ! -f /var/lib/wgnord/countries.txt ]; then
          cp ${pkgs.wgnord}/share/countries.txt /var/lib/wgnord/countries.txt
        fi
        if [ ! -f /var/lib/wgnord/countries_iso31662.txt ]; then
          cp ${pkgs.wgnord}/share/countries_iso31662.txt /var/lib/wgnord/countries_iso31662.txt
        fi
      '';

      # wgnord service for NordVPN WireGuard connection
      # Note: NordVPN automatically routes P2P traffic through appropriate servers
      # even when connected to regular servers in P2P-supported countries
      systemd.services.wgnord = {
        description = "NordVPN WireGuard (wgnord) service - P2P optimized";
        after = [ "network.target" "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.wireguard-tools
          pkgs.iproute2
          pkgs.jq
          pkgs.curl
          pkgs.coreutils
          pkgs.gnused
        ];

        script = ''
          # Ensure directories exist
          mkdir -p /var/lib/wgnord
          mkdir -p /etc/wireguard

          # Login if credentials don't exist
          if [ ! -f /var/lib/wgnord/credentials.json ]; then
            ${lib.optionalString (cfg.nordvpn.tokenFile != null) ''
              if [ -f "${cfg.nordvpn.tokenFile}" ]; then
                echo "Logging in with NordVPN token..."
                TOKEN=$(cat "${cfg.nordvpn.tokenFile}")
                ${pkgs.wgnord}/bin/wgnord l "$TOKEN"
              else
                echo "Warning: NordVPN token file not found at ${cfg.nordvpn.tokenFile}"
                exit 1
              fi
            ''}
          fi

          # Clean up any existing connection
          ${pkgs.wgnord}/bin/wgnord d 2>/dev/null || true
          ${pkgs.wireguard-tools}/bin/wg-quick down wgnord 2>/dev/null || true
          rm -f /etc/wireguard/wgnord.conf

          # Extract credentials
          PRIVKEY=$(cat /var/lib/wgnord/credentials.json | ${pkgs.jq}/bin/jq -r '.nordlynx_private_key')

          # Get P2P server
          echo "Finding best P2P server..."
          SERVER_INFO=$(${pkgs.curl}/bin/curl -s "https://api.nordvpn.com/v1/servers/recommendations?filters%5Bservers_technologies%5D%5Bidentifier%5D=wireguard_udp&filters%5Bservers_groups%5D%5Bidentifier%5D=legacy_p2p&limit=1")

          # Fallback to US servers if P2P fails
          if [ -z "$SERVER_INFO" ] || [ "$SERVER_INFO" = "[]" ]; then
            echo "No P2P servers found, using US servers..."
            SERVER_INFO=$(${pkgs.curl}/bin/curl -s "https://api.nordvpn.com/v1/servers/recommendations?filters%5Bservers_technologies%5D%5Bidentifier%5D=wireguard_udp&filters%5Bcountry_id%5D=228&limit=1")
          fi

          SERVER_IP=$(echo "$SERVER_INFO" | ${pkgs.jq}/bin/jq -r '.[0].station')
          SERVER_PUBKEY=$(echo "$SERVER_INFO" | ${pkgs.jq}/bin/jq -r '.[0].technologies[] | select(.identifier == "wireguard_udp") | .metadata[0].value')
          SERVER_NAME=$(echo "$SERVER_INFO" | ${pkgs.jq}/bin/jq -r '.[0].hostname')

          echo "Connecting to $SERVER_NAME..."

          # Create WireGuard config with split tunneling
          cat > /etc/wireguard/wgnord.conf << EOF
          [Interface]
          PrivateKey = $PRIVKEY
          Address = 10.5.0.2/16
          DNS = 103.86.96.100,103.86.99.100
          MTU = 1420
          # Split tunneling - exclude local network from VPN (ignore errors if rules already exist)
          PostUp = ip rule add from 192.168.1.0/24 table main priority 100 2>/dev/null || true; ip rule add to 192.168.1.0/24 table main priority 101 2>/dev/null || true
          PostDown = ip rule del from 192.168.1.0/24 table main priority 100 2>/dev/null || true; ip rule del to 192.168.1.0/24 table main priority 101 2>/dev/null || true

          [Peer]
          PublicKey = $SERVER_PUBKEY
          AllowedIPs = 0.0.0.0/0, ::/0
          Endpoint = ''${SERVER_IP}:51820
          EOF

          chmod 600 /etc/wireguard/wgnord.conf

          # Bring up the interface
          ${pkgs.wireguard-tools}/bin/wg-quick up wgnord

          echo "Connected successfully!"
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          # Disconnect on stop
          ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down wgnord";

          # Restart policy
          Restart = "on-failure";
          RestartSec = "30s";
          StartLimitBurst = 3;
          StartLimitIntervalSec = 300;

          # Environment - include all necessary tools
          Environment = "PATH=${pkgs.wireguard-tools}/bin:${pkgs.iproute2}/bin:${pkgs.coreutils}/bin:${pkgs.jq}/bin:${pkgs.curl}/bin:${pkgs.gnused}/bin";

          # Security - but allow network access
          PrivateTmp = false;  # wgnord might need tmp access
          ProtectHome = false;  # wgnord needs to access config files
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