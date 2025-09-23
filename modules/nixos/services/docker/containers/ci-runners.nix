# CI/CD Runner Container Module
# Manages GitHub and Forgejo runners in Docker containers
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

    github = {
      enable = lib.mkEnableOption "GitHub Actions runners";

      image = lib.mkOption {
        type = lib.types.str;
        default = "myoung34/github-runner:latest";
        description = "Docker image to use for GitHub runners";
      };

      replicas = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Number of concurrent GitHub runners";
      };

      ephemeral = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use ephemeral runners (one job per container)";
      };

      labels = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "docker" "self-hosted" "linux" "x64" ];
        description = "Labels for the GitHub runners";
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
        default = "/run/secrets/github-runner-token";
        description = "Path to file containing GitHub PAT token";
      };

      owner = lib.mkOption {
        type = lib.types.str;
        default = "nightconcept";
        description = "GitHub owner (user or organization)";
      };

      repo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Repository name (null for org-wide runners)";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional environment variables for runners";
      };

      workingDirectory = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/github-runners";
        description = "Working directory for GitHub runners";
      };
    };

    forgejo = {
      enable = lib.mkEnableOption "Forgejo Actions runners";

      image = lib.mkOption {
        type = lib.types.str;
        default = "data.forgejo.org/forgejo/runner:11";
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
    systemd.tmpfiles.rules = lib.mkMerge [
      (lib.mkIf cfg.github.enable [
        "d ${cfg.github.workingDirectory} 0755 root root -"
      ])
      (lib.mkIf cfg.forgejo.enable [
        "d ${cfg.forgejo.workingDirectory} 0755 root root -"
      ])
    ];

    # Create docker-compose files
    systemd.services = lib.mkMerge [
      # GitHub Runners Service
      (lib.mkIf cfg.github.enable {
        github-runners = {
          description = "GitHub Actions Runners";
          after = [ "network.target" "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            WorkingDirectory = cfg.github.workingDirectory;
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.github.workingDirectory}";
            ExecStart = let
              # Build environment variables with proper indentation
              baseEnvVars = [
                "                      RUNNER_SCOPE: '${if cfg.github.repo != null then "repo" else "org"}'"
                "                      LABELS: '${lib.concatStringsSep "," cfg.github.labels}'"
                "                      EPHEMERAL: '${if cfg.github.ephemeral then "true" else "false"}'"
                "                      DISABLE_AUTO_UPDATE: 'true'"
              ];
              repoEnvVars = lib.optional (cfg.github.repo != null) "                      REPO_URL: 'https://github.com/${cfg.github.owner}/${cfg.github.repo}'";
              orgEnvVars = lib.optional (cfg.github.repo == null) "                      ORG_NAME: '${cfg.github.owner}'";
              customEnvVars = lib.mapAttrsToList (name: value: "                      ${name}: '${value}'") cfg.github.environment;
              envVars = lib.concatStringsSep "\n" (baseEnvVars ++ repoEnvVars ++ orgEnvVars ++ customEnvVars);

              dockerComposeFile = pkgs.writeText "github-docker-compose.yml" ''
                version: '3.8'

                services:
                  github-runner:
                    image: ${cfg.github.image}
                    restart: unless-stopped
                    deploy:
                      replicas: ${toString cfg.github.replicas}
                    environment:
${envVars}
                    env_file:
                      - ${cfg.github.workingDirectory}/.env
                    volumes:
                      - /var/run/docker.sock:/var/run/docker.sock
                      - github-runner-work:/home/runner/_work
                    networks:
                      - runner-network

                volumes:
                  github-runner-work:

                networks:
                  runner-network:
                    driver: bridge
              '';
            in pkgs.writeScript "start-github-runners" ''
              #!${pkgs.bash}/bin/bash
              ${pkgs.coreutils}/bin/cp ${dockerComposeFile} ${cfg.github.workingDirectory}/docker-compose.yml
              echo "ACCESS_TOKEN=$(cat ${cfg.github.tokenFile})" > ${cfg.github.workingDirectory}/.env
              ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.github.workingDirectory}/docker-compose.yml up -d --scale github-runner=${toString cfg.github.replicas}
            '';
            ExecStop = ''
              ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.github.workingDirectory}/docker-compose.yml down
            '';
            Restart = "on-failure";
          };
        };
      })

      # Forgejo Runners Service
      (lib.mkIf cfg.forgejo.enable {
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
                "                      FORGEJO_INSTANCE_URL: '${cfg.forgejo.instanceUrl}'"
                "                      FORGEJO_RUNNER_NAME: '${cfg.forgejo.runnerName}'"
                "                      FORGEJO_RUNNER_LABELS: '${lib.concatStringsSep "," cfg.forgejo.labels}'"
              ];
              customEnvVars = lib.mapAttrsToList (name: value: "                      ${name}: '${value}'") cfg.forgejo.environment;
              envVars = lib.concatStringsSep "\n" (baseEnvVars ++ customEnvVars);

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

                  forgejo-runner:
                    image: ${cfg.forgejo.image}
                    restart: unless-stopped
                    deploy:
                      replicas: ${toString cfg.forgejo.replicas}
                    depends_on:
                      - docker-in-docker
                    environment:
${envVars}
                      DOCKER_HOST: 'tcp://docker-in-docker:2375'
                    env_file:
                      - ${cfg.forgejo.workingDirectory}/.env
                    volumes:
                      - forgejo-runner-data:/data
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
                          forgejo-runner register --no-interactive \
                            --instance "${cfg.forgejo.instanceUrl}" \
                            --token "$FORGEJO_RUNNER_REGISTRATION_TOKEN" \
                            --name "${cfg.forgejo.runnerName}-$HOSTNAME" \
                            --labels "${lib.concatStringsSep "," cfg.forgejo.labels}"
                        fi
                        forgejo-runner daemon

                volumes:
                  forgejo-runner-data:

                networks:
                  runner-network:
                    driver: bridge
              '';
            in pkgs.writeScript "start-forgejo-runners" ''
              #!${pkgs.bash}/bin/bash
              ${pkgs.coreutils}/bin/cp ${dockerComposeFile} ${cfg.forgejo.workingDirectory}/docker-compose.yml
              echo "FORGEJO_RUNNER_REGISTRATION_TOKEN=$(cat ${cfg.forgejo.tokenFile})" > ${cfg.forgejo.workingDirectory}/.env
              ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.forgejo.workingDirectory}/docker-compose.yml up -d --scale forgejo-runner=${toString cfg.forgejo.replicas}
            '';
            ExecStop = ''
              ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.forgejo.workingDirectory}/docker-compose.yml down
            '';
            Restart = "on-failure";
          };
        };
      })
    ];

    # Monitoring for runner containers (optional)
    # Note: Requires prometheus module to be enabled
    # services.prometheus.exporters.docker = lib.mkIf (cfg.github.enable || cfg.forgejo.enable) {
    #   enable = true;
    #   port = 9323;
    # };
  };
}