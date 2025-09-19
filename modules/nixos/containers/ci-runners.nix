# CI/CD Runner Container Module
# Manages GitHub and Forgejo runners in Docker containers
{ config, lib, pkgs, ... }:

let
  cfg = config.services.ci-runners;
in
{
  options.services.ci-runners = {
    enable = lib.mkEnableOption "CI/CD runner containers";

    github = {
      enable = lib.mkEnableOption "GitHub Actions runners";

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
    };

    forgejo = {
      enable = lib.mkEnableOption "Forgejo Actions runners";

      replicas = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Number of concurrent Forgejo runners";
      };

      instanceUrl = lib.mkOption {
        type = lib.types.str;
        description = "URL of your Forgejo instance";
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
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

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
            WorkingDirectory = "/var/lib/github-runners";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/github-runners";
            ExecStart = let
              dockerComposeFile = pkgs.writeText "github-docker-compose.yml" ''
                version: '3.8'

                services:
                  github-runner:
                    image: myoung34/github-runner:latest
                    restart: unless-stopped
                    deploy:
                      replicas: ${toString cfg.github.replicas}
                    environment:
                      - RUNNER_SCOPE=${if cfg.github.repo != null then "repo" else "org"}
                      ${lib.optionalString (cfg.github.repo != null) ''
                      - REPO_URL=https://github.com/${cfg.github.owner}/${cfg.github.repo}
                      ''}
                      ${lib.optionalString (cfg.github.repo == null) ''
                      - ORG_NAME=${cfg.github.owner}
                      ''}
                      - LABELS=${lib.concatStringsSep "," cfg.github.labels}
                      - EPHEMERAL=${if cfg.github.ephemeral then "true" else "false"}
                      - DISABLE_AUTO_UPDATE=true
                    env_file:
                      - /var/lib/github-runners/.env
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
            in ''
              ${pkgs.coreutils}/bin/cp ${dockerComposeFile} /var/lib/github-runners/docker-compose.yml
              echo "ACCESS_TOKEN=$(cat ${cfg.github.tokenFile})" > /var/lib/github-runners/.env
              ${pkgs.docker-compose}/bin/docker-compose -f /var/lib/github-runners/docker-compose.yml up -d --scale github-runner=${toString cfg.github.replicas}
            '';
            ExecStop = ''
              ${pkgs.docker-compose}/bin/docker-compose -f /var/lib/github-runners/docker-compose.yml down
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
            WorkingDirectory = "/var/lib/forgejo-runners";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/forgejo-runners";
            ExecStart = let
              dockerComposeFile = pkgs.writeText "forgejo-docker-compose.yml" ''
                version: '3.8'

                services:
                  forgejo-runner:
                    image: code.forgejo.org/forgejo/runner:latest
                    restart: unless-stopped
                    deploy:
                      replicas: ${toString cfg.forgejo.replicas}
                    environment:
                      - FORGEJO_INSTANCE_URL=${cfg.forgejo.instanceUrl}
                      - FORGEJO_RUNNER_NAME=vincent-runner
                      - FORGEJO_RUNNER_LABELS=${lib.concatStringsSep "," cfg.forgejo.labels}
                    env_file:
                      - /var/lib/forgejo-runners/.env
                    volumes:
                      - /var/run/docker.sock:/var/run/docker.sock
                      - forgejo-runner-data:/data
                    networks:
                      - runner-network

                volumes:
                  forgejo-runner-data:

                networks:
                  runner-network:
                    driver: bridge
              '';
            in ''
              ${pkgs.coreutils}/bin/cp ${dockerComposeFile} /var/lib/forgejo-runners/docker-compose.yml
              echo "FORGEJO_RUNNER_REGISTRATION_TOKEN=$(cat ${cfg.forgejo.tokenFile})" > /var/lib/forgejo-runners/.env
              ${pkgs.docker-compose}/bin/docker-compose -f /var/lib/forgejo-runners/docker-compose.yml up -d --scale forgejo-runner=${toString cfg.forgejo.replicas}
            '';
            ExecStop = ''
              ${pkgs.docker-compose}/bin/docker-compose -f /var/lib/forgejo-runners/docker-compose.yml down
            '';
            Restart = "on-failure";
          };
        };
      })
    ];

    # Monitoring for runner containers
    services.prometheus.exporters.docker = lib.mkIf (cfg.github.enable || cfg.forgejo.enable) {
      enable = true;
      port = 9323;
    };
  };
}