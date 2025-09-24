# CI/CD Runner Container Module
# Manages Forgejo runners in Docker containers
{ config, lib, pkgs, ... }:

let
  cfg = config.services.ci-runners;
in
{
  options.services.ci-runners = {
    enable = lib.mkEnableOption "CI/CD runner containers";

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/ci-runners";
      description = "Base directory for CI runner data";
    };

    forgejo = {
      enable = lib.mkEnableOption "Forgejo Actions runners";

      image = lib.mkOption {
        type = lib.types.str;
        default = "code.forgejo.org/forgejo/runner:11";
        description = "Docker image to use for Forgejo runners";
      };

      replicas = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Number of concurrent Forgejo runners";
      };

      instanceUrl = lib.mkOption {
        type = lib.types.str;
        description = "URL of your Forgejo instance";
      };

      runnerName = lib.mkOption {
        type = lib.types.str;
        default = "${config.networking.hostName}-runner";
        description = "Name for the Forgejo runner";
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

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional environment variables for runners";
      };

      workingDirectory = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/forgejo-runners";
        description = "Working directory for Forgejo runners";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories with proper permissions
    systemd.tmpfiles.rules = lib.mkIf cfg.forgejo.enable [
      "d ${cfg.forgejo.workingDirectory} 0755 root root -"
    ];

    # Create docker-compose files
    systemd.services = lib.mkIf cfg.forgejo.enable {
      forgejo-runners = {
        description = "Forgejo Actions Runners";
        after = [ "network.target" "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          WorkingDirectory = cfg.forgejo.workingDirectory;
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.forgejo.workingDirectory}";
          ExecStart = let
            # Build environment variables with proper indentation
            baseEnvVars = [
              "      FORGEJO_INSTANCE_URL: '${cfg.forgejo.instanceUrl}'"
              "      FORGEJO_RUNNER_NAME: '${cfg.forgejo.runnerName}'"
              "      FORGEJO_RUNNER_LABELS: '${lib.concatStringsSep "," cfg.forgejo.labels}'"
            ];
            customEnvVars = lib.mapAttrsToList (name: value: "      ${name}: '${value}'") cfg.forgejo.environment;
            envVars = lib.concatStringsSep "\n" (baseEnvVars ++ customEnvVars);

            # Generate individual runner services
            runnerServices = lib.concatStringsSep "\n" (lib.genList (i: let
              runnerNum = i + 1;
            in ''
  forgejo-runner-${toString runnerNum}:
    image: ${cfg.forgejo.image}
    restart: unless-stopped
    depends_on:
      - docker-in-docker
    environment:
${envVars}
      DOCKER_HOST: 'tcp://docker-in-docker:2375'
    env_file:
      - ${cfg.forgejo.workingDirectory}/.env
    volumes:
      - forgejo-runner-data-${toString runnerNum}:/data
    networks:
      - runner-network
    user: "0:0"
    command:
      - sh
      - -c
      - |
        cd /data
        if [ ! -f .runner ]; then
          sleep 5
          RUNNER_NAME="${cfg.forgejo.runnerName}-${toString runnerNum}"
          echo "Registering runner: $RUNNER_NAME"
          forgejo-runner register --no-interactive \
            --instance "${cfg.forgejo.instanceUrl}" \
            --token "$FORGEJO_RUNNER_REGISTRATION_TOKEN" \
            --name "$RUNNER_NAME" \
            --labels "${lib.concatStringsSep "," cfg.forgejo.labels}"
        fi
        forgejo-runner daemon
            '') cfg.forgejo.replicas);

            # Generate volume definitions
            runnerVolumes = lib.concatStringsSep "\n" (lib.genList (i: "  forgejo-runner-data-${toString (i + 1)}:") cfg.forgejo.replicas);

            dockerComposeFile = pkgs.writeText "forgejo-docker-compose.yml" ''
version: '3.8'

services:
  docker-in-docker:
    image: docker:dind
    privileged: true
    command: ['dockerd', '-H', 'tcp://0.0.0.0:2375', '--tls=false']
    restart: unless-stopped
    networks:
      - runner-network

${runnerServices}

volumes:
${runnerVolumes}

networks:
  runner-network:
    driver: bridge
            '';
          in pkgs.writeScript "start-forgejo-runners" ''
            #!${pkgs.bash}/bin/bash
            ${pkgs.coreutils}/bin/cp ${dockerComposeFile} ${cfg.forgejo.workingDirectory}/docker-compose.yml
            echo "FORGEJO_RUNNER_REGISTRATION_TOKEN=$(cat ${cfg.forgejo.tokenFile})" > ${cfg.forgejo.workingDirectory}/.env
            ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.forgejo.workingDirectory}/docker-compose.yml up -d
          '';
          ExecStop = ''
            ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.forgejo.workingDirectory}/docker-compose.yml down
          '';
          Restart = "on-failure";
        };
      };
    };

    # Monitoring for runner containers (optional)
    # Note: Requires prometheus module to be enabled
    # services.prometheus.exporters.docker = lib.mkIf cfg.forgejo.enable {
    #   enable = true;
    #   port = 9323;
    # };
  };
}