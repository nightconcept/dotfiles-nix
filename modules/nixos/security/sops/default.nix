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

      # IMPORTANT: System-level SOPS requires an age key at boot time
      # The key must be placed at /var/lib/sops-nix/key.txt
      # This is handled by the bootstrap script during installation
      # For existing systems, run: sudo mkdir -p /var/lib/sops-nix && echo "AGE_KEY" | sudo tee /var/lib/sops-nix/key.txt
      age.keyFile = "/var/lib/sops-nix/key.txt";

      # Fallback to SSH host keys if age key is not available
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets = {
        "ssh_keys/id_sdev" = {
          owner = "danny";
          path = "/home/danny/.ssh/id_sdev";
          mode = "0600";
        };
        "network/titan_credentials" = {
          # SOPS will handle the path automatically
          owner = "root";
          mode = "0400";
        };
        "vpn/nordvpn_token" = {
          # SOPS will handle the path automatically
          owner = "root";
          mode = "0400";
        };
      };
    };
  };
}