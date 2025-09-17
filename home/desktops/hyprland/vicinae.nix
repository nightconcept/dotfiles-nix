{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.desktops.hyprland.enable or false) {
    # Enable Vicinae service with default settings
    services.vicinae = {
      enable = true;
      autoStart = true;  # Auto-start vicinae server with session
    };

    # Generate Vicinae theme using Stylix colors
    xdg.configFile."vicinae/themes/stylix.json" = let
      colors = config.lib.stylix.colors;
    in {
      text = builtins.toJSON {
        version = "1.0.0";
        name = "Stylix Theme";
        author = "Nix Configuration";
        description = "Auto-generated theme using Stylix colors";
        colors = {
          primary = "#${colors.base0D}";      # Blue - primary accent
          secondary = "#${colors.base0E}";    # Magenta - secondary accent
          background = "#${colors.base00}";   # Dark background
          surface = "#${colors.base01}";      # Slightly lighter surface
          text = "#${colors.base05}";         # Primary text
          textSecondary = "#${colors.base04}"; # Secondary text
          border = "#${colors.base03}";       # Border color
          success = "#${colors.base0B}";      # Green - success
          warning = "#${colors.base0A}";      # Yellow - warning
          error = "#${colors.base08}";        # Red - error
        };
        borderRadius = 8;
        blur = true;
        transparency = 0.95;
      };
    };
  };
}