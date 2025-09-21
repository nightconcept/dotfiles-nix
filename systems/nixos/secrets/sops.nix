# System-level SOPS secrets configuration
{ config, pkgs, inputs, ... }:

{
  # Import sops-nix module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # SOPS configuration
  sops = {
    defaultSopsFile = ./ci-runners.yaml;
    defaultSopsFormat = "yaml";

    # Use danny's personal SSH key for decryption (converted to age)
    age.keyFile = "/home/danny/.config/sops/age/keys.txt";

    # Secrets to be deployed
    secrets = {
      "github-runner-token" = {
        path = "/run/secrets/github-runner-token";
        mode = "0400";
        owner = "root";
      };

      "forgejo-runner-token" = {
        path = "/run/secrets/forgejo-runner-token";
        mode = "0400";
        owner = "root";
      };
    };
  };
}