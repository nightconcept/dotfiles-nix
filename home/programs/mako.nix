{
  config,
  lib,
  pkgs,
  ...
}: {
  services.mako = {
    enable = true;
    
    settings = {
      # Display settings
      max-visible = 10;
      layer = "top";
      anchor = "top-right";
      margin = 20;
      
      # Font configuration
      font = "Sarasa UI SC 10";
      
      # Colors
      background-color = "#4c566add";
      text-color = "#d8dee9";
      border-color = "#434c5e";
      
      # Appearance
      border-radius = 7;
      max-icon-size = 48;
      
      # Timeout
      default-timeout = 10000;
    };
  };
}