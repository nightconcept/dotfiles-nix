{ config, pkgs, inputs, ... }:

{
  # SOPS configuration for NixOS systems
  sops = {
    # Use the host's SSH key to decrypt secrets
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    
    # Also allow using the user's converted age key if it exists
    age.keyFile = "/home/danny/.config/sops/age/keys.txt";
    
    # Generate a new age key if neither exists
    age.generateKey = false;  # We're using existing SSH keys
    
    # Default secrets file location (relative to this file)
    defaultSopsFile = ./common.yaml;
    
    # Validate that age keys exist
    validateSopsFiles = true;
    
    # Secrets definitions will be added per-host or here for common secrets
    secrets = {
      # SSH private key for user danny - deployed to the actual location
      "ssh_keys/id_sdev" = {
        owner = "danny";
        path = "/home/danny/.ssh/id_sdev";
        mode = "0600";
      };
      
      # Network mount credentials (replacement for mog-secrets)
      "network/titan_credentials" = {
        owner = "root";
        group = "root";
        path = "/etc/sops-mog-secrets";
        mode = "0600";
      };

      # NordVPN token for wgnord authentication
      "vpn/nordvpn_token" = {
        owner = "root";
        group = "root";
        path = "/run/secrets/nordvpn-token";
        mode = "0400";
      };

      # qBittorrent web UI password
      "torrent/qbittorrent_password" = {
        owner = "danny";
        group = "danny";
        path = "/run/secrets/qbittorrent-password";
        mode = "0400";
      };
    };
  };
}
