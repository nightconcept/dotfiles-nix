# GitHub Actions Runner Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.github-runner;
  containerName = "github-runner";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.github-runner = {
    enable = lib.mkEnableOption "GitHub Actions runner containers";

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

    scope = lib.mkOption {
      type = lib.types.enum [ "repo" "org" ];
      default = "repo";
      description = "Scope for runners (repository or organization)";
    };

    owner = lib.mkOption {
      type = lib.types.str;
      default = "nightconcept";
      description = "GitHub owner (user or organization)";
    };

    repo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Repository name (required for repo scope)";
      example = "dotfiles-nix";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/secrets/github-runner-token";
      description = "Path to file containing GitHub PAT token";
    };

    workDir = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/work";
      description = "Working directory for runner jobs";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d ${cfg.workDir} 0755 root root -"
    ];

    systemd.services."docker-container-${containerName}" = {
      description = "GitHub Actions Runner Containers";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Generate .env file
        cat > ${containerPath}/.env <<EOF
        RUNNER_SCOPE=${cfg.scope}
        ${lib.optionalString (cfg.scope == "repo") ''
        REPO_URL=https://github.com/${cfg.owner}/${cfg.repo}
        ''}
        ${lib.optionalString (cfg.scope == "org") ''
        ORG_NAME=${cfg.owner}
        ''}
        LABELS=${lib.concatStringsSep "," cfg.labels}
        EPHEMERAL=${if cfg.ephemeral then "true" else "false"}
        EOF

        # Add token from secrets file
        if [ -f ${cfg.tokenFile} ]; then
          echo "GITHUB_TOKEN=$(cat ${cfg.tokenFile})" >> ${containerPath}/.env
        else
          echo "Warning: GitHub token file not found at ${cfg.tokenFile}"
        fi

        # Scale to desired replicas
        ${pkgs.yq}/bin/yq -i '
          .services.github-runner.deploy.replicas = ${toString cfg.replicas}
        ' ${containerPath}/docker-compose.yml
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = containerPath;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --scale github-runner=${toString cfg.replicas}";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        ExecReload = "${pkgs.docker-compose}/bin/docker-compose restart";
      };
    };
  };
}