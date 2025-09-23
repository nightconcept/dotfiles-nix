# Jellyfin Media Server Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.jellyfin;
  containerName = "jellyfin";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin media server container";

    publishedServerUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://jellyfin.local.solivan.dev";
      description = "Published server URL for Jellyfin";
      example = "https://jellyfin.example.com";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Chicago";
      description = "Timezone for Jellyfin";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/config";
      description = "Path to Jellyfin configuration";
    };

    mediaPaths = {
      tvShows = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/titan/TVShows";
        description = "Path to TV shows library";
      };

      movies = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/titan/Movies";
        description = "Path to movies library";
      };

      additionalPaths = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Mount name in container";
              example = "music";
            };
            hostPath = lib.mkOption {
              type = lib.types.str;
              description = "Host path to media";
              example = "/mnt/storage/Music";
            };
          };
        });
        default = [];
        description = "Additional media paths to mount";
      };
    };

    ports = {
      webUI = lib.mkOption {
        type = lib.types.int;
        default = 8096;
        description = "Web UI port";
      };

      https = lib.mkOption {
        type = lib.types.int;
        default = 8920;
        description = "HTTPS port";
      };

      discovery = lib.mkOption {
        type = lib.types.int;
        default = 7359;
        description = "Client discovery port (UDP)";
      };

      dlna = lib.mkOption {
        type = lib.types.int;
        default = 1900;
        description = "DLNA port (UDP)";
      };
    };

    enableWatchtower = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Watchtower auto-updates";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories
    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d ${cfg.configPath} 0755 root root -"
    ];

    # Jellyfin container service
    systemd.services."docker-container-${containerName}" = {
      description = "Jellyfin Media Server Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Generate docker-compose.yml directly
        cat > ${containerPath}/docker-compose.yml <<EOF
        version: "3"

        services:
          jellyfin:
            image: linuxserver/jellyfin:latest
            container_name: jellyfin
            restart: unless-stopped
            environment:
              - JELLYFIN_PublishedServerUrl=${cfg.publishedServerUrl}
              - TZ=${cfg.timezone}
            ports:
              - "${toString cfg.ports.webUI}:8096"
              - "${toString cfg.ports.https}:8920"
              - "${toString cfg.ports.discovery}:7359/udp"
              - "${toString cfg.ports.dlna}:1900/udp"
            volumes:
              - ${cfg.configPath}:/config
              - ${cfg.mediaPaths.tvShows}:/data/tvshows
              - ${cfg.mediaPaths.movies}:/data/movies
        ${lib.concatMapStrings (path: ''
              - ${path.hostPath}:/data/${path.name}
        '') cfg.mediaPaths.additionalPaths}
            labels:
              - "com.centurylinklabs.watchtower.enable=${toString cfg.enableWatchtower}"
        EOF
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = containerPath;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        ExecReload = "${pkgs.docker-compose}/bin/docker-compose restart";
      };
    };

    # Open firewall ports
    networking.firewall = {
      allowedTCPPorts = [ cfg.ports.webUI cfg.ports.https ];
      allowedUDPPorts = [ cfg.ports.discovery cfg.ports.dlna ];
    };
  };
}