{
  config,
  pkgs,
  ...
}: let
  laptop_lid_switch = pkgs.writeShellScriptBin "laptop_lid_switch" ''
    #!/usr/bin/env bash

    if grep open /proc/acpi/button/lid/LID0/state; then
    		hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1"
    else
    		if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
    				hyprctl keyword monitor "eDP-1, disable"
    		else
    				systemctl suspend
    		fi
    fi
  '';

  resize = pkgs.writeShellScriptBin "resize" ''
    #!/usr/bin/env bash

    #  Initially inspired by https://github.com/exoess

    # Getting some information about the current window
    # windowinfo=$(hyprctl activewindow) removes the newlines and won't work with grep
    hyprctl activewindow > /tmp/windowinfo
    windowinfo=/tmp/windowinfo

    # Run slurp to get position and size
    if ! slurp=$(slurp); then
    		exit
    fi

    # Parse the output
    pos_x=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 1)
    pos_y=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 2)
    size_x=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 1)
    size_y=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 2)

    # Keep the aspect ratio intact for PiP
    if grep "title: Picture-in-Picture" $windowinfo; then
    		old_size=$(grep "size: " $windowinfo | cut -d " " -f 2)
    		old_size_x=$(echo $old_size | cut -d , -f 1)
    		old_size_y=$(echo $old_size | cut -d , -f 2)

    		size_x=$(((old_size_x * size_y + old_size_y / 2) / old_size_y))
    		echo $old_size_x $old_size_y $size_x $size_y
    fi

    # Resize and move the (now) floating window
    grep "fullscreen: 1" $windowinfo && hyprctl dispatch fullscreen
    grep "floating: 0" $windowinfo && hyprctl dispatch togglefloating
    hyprctl dispatch moveactive exact $pos_x $pos_y
    hyprctl dispatch resizeactive exact $size_x $size_y

  '';
in {
  imports = [
    ./hyprland-environment.nix
  ];

  config = {
    home.packages = with pkgs; [
      waybar
      swww
      slurp
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;

      settings = {
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "swww init && sleep 0.1 && swww img ~/git/dotfiles-nix/home/desktops/wallpaper/main.jpg"
          "waybar"
          "kanshi"
          "hyprctl keyword monitor eDP-1, ,preferred, auto, 1"
        ];

        input = {
          kb_layout = "us";
          touchpad = {
            disable_while_typing = false;
            natural_scroll = false;
          };
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(88888888)";
          "col.inactive_border" = "rgba(00000088)";

          allow_tearing = true;
          resize_on_border = true;
        };

        decoration = {
          rounding = 16;
          blur = {
            enabled = true;
            brightness = 1.0;
            contrast = 1.0;
            noise = 0.02;

            passes = 3;
            size = 10;
          };

          drop_shadow = true;
          shadow_ignore_window = true;
          shadow_offset = "0 2";
          shadow_range = 20;
          shadow_render_power = 3;
          "col.shadow" = "rgba(00000055)";
        };

        animations = {
          enabled = true;
          animation = [
            "border, 1, 2, default"
            "fade, 1, 4, default"
            "windows, 1, 3, default, popin 80%"
            "workspaces, 1, 2, default, slide"
          ];
        };

        "$mod" = "SUPER";
        bind = [
          "$mod, T, exec, wezterm"
          "$mod, F, exec, firefox"
          "$mod, E, exec, code"
          "$mod, R, exec, rofiWindow"
          "$mod, Q, killactive"
          "$mod, V, togglefloating"
          "$mod, backspace, exec, wlogout --column-spacing 50 --row-spacing 50"
          "$mod, a, exec, rofi -show drun -mode drun"

          # Switch workspaces with mod + [0-9]
          "$mod, 1, workspace,01"
          "$mod, 2, workspace,02"
          "$mod, 3, workspace,03"
          "$mod, 4, workspace,04"
          "$mod, 5, workspace,05"
          "$mod, 6, workspace,06"
          "$mod, 7, workspace,07"
          "$mod, 8, workspace,08"
          "$mod, 9, workspace,09"
          "$mod, 0, workspace,10"

          "SUPER,backspace, exec,swaylock -S"

          # Screenshot
          ",Print, exec,grimblast --notify copysave area"
          "SHIFT, Print, exec,grimblast --notify copy active"
          "CONTROL,Print, exec,grimblast --notify copy screen"
          "SUPER,Print, exec,grimblast --notify copy window"
          "ALT,Print, exec,grimblast --notify copy area"
          "SUPER,bracketleft, exec,grimblast --notify --cursor copysave area ~/Pictures/$(date \" + %Y-%m-%d \"T\"%H:%M:%S_no_watermark \").png"
          "SUPER,bracketright, exec, grimblast --notify --cursor copy area"

          # Move Workspace
          "SUPERSHIFT,1, movetoworkspacesilent,01"
          "SUPERSHIFT,2, movetoworkspacesilent,02"
          "SUPERSHIFT,3, movetoworkspacesilent,03"
          "SUPERSHIFT,4, movetoworkspacesilent,04"
          "SUPERSHIFT,5, movetoworkspacesilent,05"
          "SUPERSHIFT,6, movetoworkspacesilent,06"
          "SUPERSHIFT,7, movetoworkspacesilent,07"
          "SUPERSHIFT,8, movetoworkspacesilent,08"
          "SUPERSHIFT,9, movetoworkspacesilent,09"
          "SUPERSHIFT,0, movetoworkspacesilent,10"

          # Swap windows
          "SUPERSHIFT,h, swapwindow,l"
          "SUPERSHIFT,l, swapwindow,r"
          "SUPERSHIFT,k, swapwindow,u"
          "SUPERSHIFT,j, swapwindow,d"
        ];

        bindi = [
          ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl +5%"
          ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -5% "
          ",XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ",XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
          ",XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
          ",XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute"
          ",XF86AudioNext, exec,playerctl next"
          ",XF86AudioPrev, exec,playerctl previous"
          ",XF86AudioPlay, exec,playerctl play-pause"
          ",XF86AudioStop, exec,playerctl stop"
        ];
        bindl = [
          ",switch:Lid Switch, exec, ${laptop_lid_switch}/bin/laptop_lid_switch"
        ];

        binde = [
          "SUPERALT, h, resizeactive, -20 0"
          "SUPERALT, l, resizeactive, 20 0"
          "SUPERALT, k, resizeactive, 0 -20"
          "SUPERALT, j, resizeactive, 0 20"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        misc = {
          force_default_wallpaper = 0;

          # disable dragging animation
          animate_mouse_windowdragging = false;

          # enable variable refresh rate (effective depending on hardware)
          vrr = 1;

          # lower the amount of sent frames when nothing is happening on-screen
          vfr = true;

          # we do, in fact, want direct scanout
          no_direct_scanout = false;
        };
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
  };
}
