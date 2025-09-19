{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker;
in
{
  imports = [
    # Core infrastructure
    ./containers/traefik
    ./containers/portainer
    ./containers/watchtower

    # CI/CD runners
    ./containers/github-runner
    ./containers/forgejo-runner

    # Media services
    ./containers/jellyfin

    # *arr stack
    ./containers/prowlarr
    ./containers/radarr
    ./containers/sonarr

    # Add other containers as default.nix files are created
    # ./containers/audiobookshelf
    # ./containers/authelia
    # ./containers/calibre
    # ./containers/calibre-web
    # ./containers/cloudflare-tunnel
    # ./containers/ddclient
    # ./containers/enshrouded
    # ./containers/flaresolverr
    # ./containers/forgejo
    # ./containers/homepage
    # ./containers/immich
    # ./containers/minecraft
    # ./containers/nextcloud
    # ./containers/open-webui
    # ./containers/palworld
    # ./containers/prowlarr-abb
    # ./containers/readarr
    # ./containers/readarr-books
    # ./containers/searxng
    # ./containers/uptime-kuma
    # ./containers/vaultwarden
    # ./containers/wg-easy
  ];

  options.modules.nixos.docker = {
    enable = lib.mkEnableOption "Docker container runtime";

    dockerComposeProjects = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Docker Compose projects to manage";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    users.users.danny.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
      yq  # For manipulating docker-compose.yml files
    ];

    # Create base directories
    systemd.tmpfiles.rules = [
      "d /var/lib/docker-containers 0755 root root -"
    ];
  };
}