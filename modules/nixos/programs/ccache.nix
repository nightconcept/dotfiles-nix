# CCache configuration for faster C/C++ compilation
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.nixos.programs.ccache;
in
{
  options.modules.nixos.programs.ccache = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable ccache for faster C/C++ compilation";
    };
  };

  config = mkIf cfg.enable {
    programs.ccache = {
      enable = true;
    };

    # Allow ccache in Nix sandbox
    nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };
}