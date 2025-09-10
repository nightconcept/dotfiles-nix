{
  lib,
  pkgs,
  ...
}: {
  # JankyBorders configuration
  # Note: JankyBorders is installed via Homebrew, this module only manages the config
  
  xdg.configFile."borders/bordersrc" = {
    text = ''
      #!/bin/bash
      
      # JankyBorders configuration - Tokyo Night default theme
      # Colors from Tokyo Night default color palette
      options=(
          style=round
          width=3.0
          hidpi=off
          active_color=0xff7aa2f7     # Tokyo Night blue - active window border
          inactive_color=0xff565f89   # Tokyo Night grey - inactive window border
      )
      
      borders "''${options[@]}"
    '';
    executable = true;
  };
}