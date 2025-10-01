# Forgejo Runner Container Module
# Manages Forgejo runners in Docker containers
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.forgejo-runners;
in {
  options.services.forgejo-runners = {
    enable = lib.mkEnableOption "Forgejo Actions runners";

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/forgejo-runners";
      description = "Base directory for Forgejo runner data";
    };

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
      example = "https://forge.solivan.dev";
    };

    runnerName = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}-runner";
      description = "Base name for the Forgejo runners";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["docker" "amd64" "linux" "ubuntu-latest"];
      description = "Labels for the Forgejo runners";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/secrets/forgejo_runner_token";
      description = "Path to file containing Forgejo registration token";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables for runners";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.workingDirectory} 0755 root root -"
    ];

    # Forgejo Runners Service
    systemd.services.forgejo-runners = {
      description = "Forgejo Actions Runners";
      after = ["network.target" "docker.service"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = cfg.workingDirectory;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.workingDirectory}";
        ExecStart = let
          # Build environment variables with proper indentation
          baseEnvVars = [
            "      FORGEJO_INSTANCE_URL: '${cfg.instanceUrl}'"
            "      FORGEJO_RUNNER_NAME: '${cfg.runnerName}'"
            "      FORGEJO_RUNNER_LABELS: '${lib.concatStringsSep "," cfg.labels}'"
          ];
          customEnvVars = lib.mapAttrsToList (name: value: "      ${name}: '${value}'") cfg.environment;
          envVars = lib.concatStringsSep "\n" (baseEnvVars ++ customEnvVars);

          # Generate individual runner services
          runnerServices = lib.concatStringsSep "\n" (lib.genList (i: let
              runnerNum = i + 1;
            in ''
                forgejo-runner-${toString runnerNum}:
                  image: ${cfg.image}
                  restart: unless-stopped
                  depends_on:
                    - docker-in-docker
                  environment:
              ${envVars}
                    DOCKER_HOST: 'tcp://docker-in-docker:2375'
                  env_file:
                    - ${cfg.workingDirectory}/.env
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
                        RUNNER_NAME="${cfg.runnerName}-${toString runnerNum}"
                        echo "Registering runner: ''${RUNNER_NAME}"
                        forgejo-runner register --no-interactive \
                          --instance "${cfg.instanceUrl}" \
                          --token "''${FORGEJO_RUNNER_REGISTRATION_TOKEN}" \
                          --name "''${RUNNER_NAME}" \
                          --labels "${lib.concatStringsSep "," cfg.labels}"
                      fi
                      forgejo-runner daemon
            '')
            cfg.replicas);

          # Generate volume definitions
          runnerVolumes = lib.concatStringsSep "\n" (lib.genList (i: "  forgejo-runner-data-${toString (i + 1)}:") cfg.replicas);

          dockerComposeFile = pkgs.writeText "forgejo-docker-compose.yml" ''
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
        in
          pkgs.writeScript "start-forgejo-runners" ''
            #!${pkgs.bash}/bin/bash
            ${pkgs.coreutils}/bin/cp ${dockerComposeFile} ${cfg.workingDirectory}/docker-compose.yml
            echo "FORGEJO_RUNNER_REGISTRATION_TOKEN=$(cat ${cfg.tokenFile})" > ${cfg.workingDirectory}/.env
            ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.workingDirectory}/docker-compose.yml up -d
          '';
        ExecStop = ''
          ${pkgs.docker-compose}/bin/docker-compose -f ${cfg.workingDirectory}/docker-compose.yml down
        '';
        Restart = "on-failure";
      };
    };
  };
}
