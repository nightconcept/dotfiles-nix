# Sonarr TV Series Manager Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.sonarr;
  containerName = "sonarr";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.sonarr = {
    enable = lib.mkEnableOption "Sonarr TV series manager container";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/config";
      description = "Path to Sonarr configuration";
    };

    downloadsPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/downloads";
      description = "Path to downloads directory";
    };

    tvShowsPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/TVShows";
      description = "Path to TV shows library";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8989;
      description = "Port for Sonarr web interface";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing secrets";
      example = "/run/secrets/sonarr-env";
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

    # Container service
    systemd.services."docker-container-${containerName}" = {
      description = "Sonarr TV Series Manager Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        if [ -f ${./docker-compose.yml} ]; then
          cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml
        else
          # Create a basic docker-compose.yml if not exists
          cat > ${containerPath}/docker-compose.yml <<'COMPOSE'
        services:
          sonarr:
            container_name: sonarr
            image: linuxserver/sonarr:latest
            restart: unless-stopped
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=America/Chicago
            ports:
              - ${toString cfg.port}:8989
            volumes:
              - ${cfg.configPath}:/config
              - ${cfg.downloadsPath}:/downloads
              - ${cfg.tvShowsPath}:/tv
        COMPOSE
        fi

        # Generate .env file
        cat > ${containerPath}/.env <<EOF
        CONFIG_PATH=${cfg.configPath}
        DOWNLOADS_PATH=${cfg.downloadsPath}
        TVSHOWS_PATH=${cfg.tvShowsPath}
        WEBUI_PORT=${toString cfg.port}
        EOF

        # Append secrets if environment file exists
        ${lib.optionalString (cfg.environmentFile != null) ''
          if [ -f ${cfg.environmentFile} ]; then
            cat ${cfg.environmentFile} >> ${containerPath}/.env
          fi
        ''}
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
  };
}