{ config, pkgs, ... }:

{
  imports = [ 
    ./keybindings.nix
    ./windowrules.nix
  ];

  home.packages = with pkgs; [ 
    waybar
    swww
  ];
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    reloadConfig
    recommendedEnvironment = true;
    systemdIntegration = true;

    config = {
      input = {
        kb_layout = "us";
        touchpad = {
          disable_while_typing = false;
        };
      };

      decoration = {
        rounding = 5;
      };

      misc = let
        FULLSCREEN_ONLY = 2;
      in {
        vrr = 2;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        variable_framerate = true;
        variable_refresh = FULLSCREEN_ONLY;
        disable_autoreload = true;
      };


      exec_once = [
        #"${pkgs.waybar}/bin/waybar"
      ];
    }
  }
}
