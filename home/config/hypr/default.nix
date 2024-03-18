{ config, pkgs, ... }:

{
  imports = [ 
    #./keybindings.nix
    #./windowrules.nix
  ];

  home.packages = with pkgs; [ 
    waybar
    swww
  ];
   
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      input = {
        kb_layout = "us";
        touchpad = {
          disable_while_typing = false;
          natural_scroll = false;
        };
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      decoration = {
        rounding = 5;
        blur = true;
        blur_size = 3;
        blur_passes = 1;
        
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        col.shadow = "gba(1a1a1aee)";
      };

      "$mod" = "SUPER";
      bind = [
        "$mod, T, exec, wezterm"
        "$mod, F, exec, firefox"
        "$mod, E, exec, code"
        "$mod, R, exec, rofiWindow"
        "$mod, E, exit"
        "$mod, Q, killactive"
        "$mod, V, togglefloating"

        # Switch workspaces with mod + [0-9]


      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      source = /home/danny/.config/hypr/colors
    '';
  };

  home.file.".config/hypr/colors".text = ''
    $background = rgba(1d192bee)
    $foreground = rgba(c3dde7ee)

    $color0 = rgba(1d192bee)
    $color1 = rgba(465EA7ee)
    $color2 = rgba(5A89B6ee)
    $color3 = rgba(6296CAee)
    $color4 = rgba(73B3D4ee)
    $color5 = rgba(7BC7DDee)
    $color6 = rgba(9CB4E3ee)
    $color7 = rgba(c3dde7ee)
    $color8 = rgba(889aa1ee)
    $color9 = rgba(465EA7ee)
    $color10 = rgba(5A89B6ee)
    $color11 = rgba(6296CAee)
    $color12 = rgba(73B3D4ee)
    $color13 = rgba(7BC7DDee)
    $color14 = rgba(9CB4E3ee)
    $color15 = rgba(c3dde7ee)
  '';
}
