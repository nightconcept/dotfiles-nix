{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
in
{
  options.modules.home.themes.stylix = {
    enable = mkBoolOpt false "Enable Stylix theming with Tokyo Night";
  };

  # Empty config - stylix module is only meant to be used on systems with stylix available
  # This prevents errors on server systems where stylix home-manager module isn't loaded
  config = {};
}