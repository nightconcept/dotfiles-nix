{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  moduleLib = import ../../../lib/module {inherit lib;};
  inherit (moduleLib) mkBoolOpt;

  # Check if we have inputs available (for flake-based configs)
  hasInputs = builtins.hasAttr "inputs" (builtins.functionArgs (import <nixpkgs> {})) || inputs != null;
in {
  options.modules.home.programs.firefox = {
    enable = mkBoolOpt false "Enable Firefox";
  };

  config = lib.mkIf config.modules.home.programs.firefox.enable {
    programs.firefox = {
      enable = true;
    };
  };
}
