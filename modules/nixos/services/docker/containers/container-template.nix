# Generic Docker Container Module Template
# This template provides a base structure for docker-compose based containers
{ containerName, defaultPort, description }:
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.${containerName};
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.${containerName} = {
    enable = lib.mkEnableOption "${description}";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/config";
      description = "Path to ${containerName} configuration";
    };

    dataPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/data";
      description = "Path to ${containerName} data";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = defaultPort;
      description = "Port for ${containerName} web interface";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file containing secrets";
      example = "/run/secrets/${containerName}-env";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables";
      example = {
        TZ = "America/Chicago";
        PUID = "1000";
        PGID = "1000";
      };
    };

    extraVolumes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional volume mounts in docker-compose format";
      example = [ "/mnt/data:/data" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories
    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d ${cfg.configPath} 0755 root root -"
      "d ${cfg.dataPath} 0755 root root -"
    ];

    # Container service
    systemd.services."docker-container-${containerName}" = {
      description = "${description} Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        if [ -f ${./docker-compose.yml} ]; then
          cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml
        else
          echo "Error: docker-compose.yml not found for ${containerName}"
          exit 1
        fi

        # Generate .env file from extraEnvironment
        cat > ${containerPath}/.env <<EOF
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${value}") cfg.extraEnvironment)}
        EOF

        # Append environment file if specified
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

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}