# Audiobookshelf audiobook and podcast server module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.audiobookshelf;
  containerName = "audiobookshelf";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.audiobookshelf = {
    enable = lib.mkEnableOption "Audiobookshelf audiobook and podcast server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "local.solivan.dev";
      description = "Base domain for Audiobookshelf";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "audiobookshelf";
      description = "Subdomain for Audiobookshelf";
    };

    audiobooksPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/Audiobooks";
      description = "Path to audiobooks library";
    };

    podcastsPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/titan/Podcasts";
      description = "Path to podcasts library";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "/home/danny/docker/audiobookshelf/audiobookshelf";
      description = "Path to Audiobookshelf configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories
    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d /home/danny/docker/audiobookshelf 0755 danny users -"
    ];

    # Audiobookshelf container service
    systemd.services."docker-container-${containerName}" = {
      description = "Audiobookshelf Audiobook and Podcast Server Container";
      after = [ "docker.service" "docker-network-proxy.service" "mnt-titan.mount" ];
      requires = [ "docker.service" "docker-network-proxy.service" ];
      wants = [ "mnt-titan.mount" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Create .env file with configuration
        cat > ${containerPath}/.env <<EOF
        PUID=1000
        PGID=1000
        AUDIOBOOKS_PATH=${cfg.audiobooksPath}
        PODCASTS_PATH=${cfg.podcastsPath}
        CONFIG_PATH=${cfg.configPath}
        DOMAIN=${cfg.domain}
        SUBDOMAIN=${cfg.subdomain}
        EOF

        # Ensure config directories have correct permissions
        chown -R danny:users ${cfg.configPath}
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