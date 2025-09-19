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
      default = "";
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
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Generate .env file
        cat > ${containerPath}/.env <<EOF
        JELLYFIN_PublishedServerUrl=${cfg.publishedServerUrl}
        TZ=${cfg.timezone}
        CONFIG_PATH=${cfg.configPath}
        TVSHOWS_PATH=${cfg.mediaPaths.tvShows}
        MOVIES_PATH=${cfg.mediaPaths.movies}
        WEBUI_PORT=${toString cfg.ports.webUI}
        HTTPS_PORT=${toString cfg.ports.https}
        DISCOVERY_PORT=${toString cfg.ports.discovery}
        DLNA_PORT=${toString cfg.ports.dlna}
        EOF

        # Update docker-compose.yml with runtime values
        ${pkgs.yq}/bin/yq -i '
          .services.jellyfin.environment[0] = "JELLYFIN_PublishedServerUrl=${cfg.publishedServerUrl}" |
          .services.jellyfin.environment[1] = "TZ=${cfg.timezone}" |
          .services.jellyfin.ports[0].published = "${toString cfg.ports.webUI}" |
          .services.jellyfin.ports[1].published = "${toString cfg.ports.https}" |
          .services.jellyfin.ports[2].published = "${toString cfg.ports.discovery}" |
          .services.jellyfin.ports[3].published = "${toString cfg.ports.dlna}" |
          .services.jellyfin.volumes[0].source = "${cfg.configPath}" |
          .services.jellyfin.volumes[1].source = "${cfg.mediaPaths.tvShows}" |
          .services.jellyfin.volumes[2].source = "${cfg.mediaPaths.movies}"
        ' ${containerPath}/docker-compose.yml

        # Add additional media paths if configured
        ${lib.concatMapStrings (path: ''
          ${pkgs.yq}/bin/yq -i '
            .services.jellyfin.volumes += [{
              "type": "bind",
              "source": "${path.hostPath}",
              "target": "/data/${path.name}"
            }]
          ' ${containerPath}/docker-compose.yml
        '') cfg.mediaPaths.additionalPaths}

        # Update watchtower label
        ${pkgs.yq}/bin/yq -i '
          .services.jellyfin.labels[0] = "com.centurylinklabs.watchtower.enable=${toString cfg.enableWatchtower}"
        ' ${containerPath}/docker-compose.yml
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