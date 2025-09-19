# Nix configuration module
{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.modules.nixos.core.nix;
in
{
  options.modules.nixos.core.nix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Nix configuration";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = true;
        trusted-users = ["root" "@wheel" "danny"];
        experimental-features = ["nix-command" "flakes"];
        use-xdg-base-directories = true;
        warn-dirty = false;
        keep-outputs = true;
        keep-derivations = true;
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 7d --max-generations 10";
      };
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config.allowUnfree = true;
    };
  };
}