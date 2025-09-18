{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
in
{
  options.modules.home.programs.wezterm = {
    enable = mkBoolOpt false "Enable WezTerm terminal emulator";
  };

  config = lib.mkIf config.modules.home.programs.wezterm.enable {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = builtins.readFile ./config.lua;
    };
  };
}