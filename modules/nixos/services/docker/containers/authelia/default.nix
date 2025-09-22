# Authelia Authentication Container Module
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker.containers.authelia;
  containerName = "authelia";
  containerPath = "/var/lib/docker-containers/${containerName}";
in
{
  options.modules.nixos.docker.containers.authelia = {
    enable = lib.mkEnableOption "Authelia authentication service";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "local.solivan.dev";
      description = "Base domain for Authelia";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "auth";
      description = "Subdomain for Authelia (e.g., auth.domain.com)";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${containerPath}/config";
      description = "Path to Authelia configuration files";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled
    virtualisation.docker.enable = true;

    # Create required directories
    systemd.tmpfiles.rules = [
      "d ${containerPath} 0755 root root -"
      "d ${cfg.configPath} 0755 root root -"
    ];

    # Authelia container service
    systemd.services."docker-container-${containerName}" = {
      description = "Authelia Authentication Service Container";
      after = [ "docker.service" "docker-network-proxy.service" ];
      requires = [ "docker.service" "docker-network-proxy.service" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy docker-compose.yml to runtime directory
        cp ${./docker-compose.yml} ${containerPath}/docker-compose.yml

        # Generate .env file if needed
        cat > ${containerPath}/.env <<EOF
        CONFIG_PATH=${cfg.configPath}
        DOMAIN=${cfg.domain}
        SUBDOMAIN=${cfg.subdomain}
        EOF
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