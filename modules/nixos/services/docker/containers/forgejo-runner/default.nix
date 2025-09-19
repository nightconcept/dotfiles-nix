# Forgejo Actions Runner Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.forgejo-runner;
  containerName = "forgejo-runner";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.forgejo-runner = {
    enable = lib.mkEnableOption "Forgejo Actions runner containers";

    replicas = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Number of concurrent Forgejo runners";
    };

    instanceUrl = lib.mkOption {
      type = lib.types.str;
      description = "URL of your Forgejo instance";
      example = "https://git.example.com";
    };

    runnerName = lib.mkOption {
      type = lib.types.str;
      default = "vincent-runner";
      description = "Base name for the runners";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "docker" "amd64" "linux" ];
      description = "Labels for the Forgejo runners";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/secrets/forgejo-runner-token";
      description = "Path to file containing Forgejo registration token";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/data";
      description = "Data directory for runner state";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d ${cfg.dataDir} 0755 root root -"
    ];

    systemd.services."docker-container-${containerName}" = {
      description = "Forgejo Actions Runner Containers";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Generate .env file
        cat > ${containerPath}/.env <<EOF
        FORGEJO_INSTANCE_URL=${cfg.instanceUrl}
        RUNNER_NAME=${cfg.runnerName}
        LABELS=${lib.concatStringsSep "," cfg.labels}
        EOF

        # Add token from secrets file
        if [ -f ${cfg.tokenFile} ]; then
          echo "FORGEJO_RUNNER_TOKEN=$(cat ${cfg.tokenFile})" >> ${containerPath}/.env
        else
          echo "Warning: Forgejo token file not found at ${cfg.tokenFile}"
        fi

        # Update volumes for data persistence
        ${pkgs.yq}/bin/yq -i '
          .services.forgejo-runner.volumes[1] = "${cfg.dataDir}:/data"
        ' ${containerPath}/docker-compose.yml

        # Scale to desired replicas
        ${pkgs.yq}/bin/yq -i '
          .services.forgejo-runner.deploy.replicas = ${toString cfg.replicas}
        ' ${containerPath}/docker-compose.yml
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = containerPath;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --scale forgejo-runner=${toString cfg.replicas}";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        ExecReload = "${pkgs.docker-compose}/bin/docker-compose restart";
      };
    };
  };
}