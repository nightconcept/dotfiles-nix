# Watchtower Auto-Update Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.watchtower;
  containerName = "watchtower";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.watchtower = {
    enable = lib.mkEnableOption "Watchtower container auto-updater";

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "0 0 4 * * *";
      description = "Cron schedule for updates";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing secrets";
      example = "/run/secrets/watchtower-env";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
    ];

    systemd.services."docker-container-${containerName}" = {
      description = "Watchtower Auto-Update Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml if exists, otherwise create basic one
        if [ -f ${./docker-compose.yml} ]; then
          cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml
        else
          cat > ${containerPath}/docker-compose.yml <<'COMPOSE'
        services:
          watchtower:
            container_name: watchtower
            image: containrrr/watchtower:latest
            restart: unless-stopped
            environment:
              - WATCHTOWER_CLEANUP=true
              - WATCHTOWER_LABEL_ENABLE=true
              - WATCHTOWER_SCHEDULE=${cfg.schedule}
            volumes:
              - /var/run/docker.sock:/var/run/docker.sock
        COMPOSE
        fi

        # Generate .env file
        echo "WATCHTOWER_SCHEDULE=${cfg.schedule}" > ${containerPath}/.env

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
      };
    };
  };
}