{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
  
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  options.modules.home.programs.spotify = {
    enable = mkBoolOpt false "Enable Spicetify for Spotify customization";
  };

  config = lib.mkIf config.modules.home.programs.spotify.enable {
    programs.spicetify = {
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      # Theme is handled by Stylix - no need to set it manually
    };
  };
}