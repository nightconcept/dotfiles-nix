# Radarr Movie Manager Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.radarr;
  containerName = "radarr";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.radarr = {
    enable = lib.mkEnableOption "Radarr movie manager container";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/config";
      description = "Path to Radarr configuration";
    };

    downloadsPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/downloads";
      description = "Path to downloads directory";
    };

    moviesPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/Movies";
      description = "Path to movies library";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 7878;
      description = "Port for Radarr web interface";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing secrets";
      example = "/run/secrets/radarr-env";
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
      description = "Radarr Movie Manager Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Generate .env file
        cat > ${containerPath}/.env <<EOF
        CONFIG_PATH=${cfg.configPath}
        DOWNLOADS_PATH=${cfg.downloadsPath}
        MOVIES_PATH=${cfg.moviesPath}
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