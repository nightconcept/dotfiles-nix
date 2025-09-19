# SOPS secrets management module
{ config, lib, ... }:

with lib;

let
  cfg = config.modules.nixos.security.sops;
in
{
  options.modules.nixos.security.sops = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SOPS secret management";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = ./common.yaml;
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets = {
        "ssh_keys/id_sdev" = {
          owner = "danny";
          path = "/home/danny/.ssh/id_sdev";
        };
        "network/titan_credentials" = {
          path = "/run/secrets/network/titan_credentials";
        };
        "vpn/nordvpn_token" = {
          path = "/run/secrets/nordvpn-token";
        };
      };
    };
  };
}