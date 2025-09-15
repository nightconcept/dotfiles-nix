{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.swaylock = {
    enable = true;
    
    settings = {
      # Basic settings
      ignore-empty-password = true;
      disable-caps-lock-text = true;
      font = "Cantarelle Regular";
      
      # Screenshot effects
      screenshots = true;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      
      # Indicator settings
      indicator = true;
      indicator-radius = 120;
      indicator-thickness = 20;
      
      # Clock display
      clock = true;
      timestr = "%I:%M %p";
      datestr = "%A, %d %B";
      
      # Colors (CachyOS theme)
      ring-color = "00aa84";
      key-hl-color = "82dccc";
      line-color = "007d6f";
      separator-color = "111826";
      inside-color = "111826";
      bs-hl-color = "01ccff";
      layout-bg-color = "111826";
      layout-border-color = "00aa84";
      layout-text-color = "ffffff";
      text-color = "ffffff";
    };
  };
}