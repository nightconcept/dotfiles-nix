{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./waybar-style.nix
    ./waybar-scripts.nix
  ];

  config = lib.mkIf (config.desktops.hyprland.enable or false) {
    programs.waybar = {
    enable = true;
    
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 3;
        
        margin-left = 0;
        margin-bottom = 0;
        margin-right = 0;
        
        modules-left = [
          "custom/power"
          "hyprland/workspaces"
          "custom/spotify"
        ];
        
        modules-center = [
        ];
        
        modules-right = [
          "backlight"
          "wireplumber"
          "bluetooth"
          "battery"
          "tray"
          "clock#date"
        ];
        
        # Modules configuration
        "hyprland/workspaces" = {
          all-outputs = true;
          format = "{name}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1 1>/dev/null";
          on-scroll-down = "hyprctl dispatch workspace e-1 1>/dev/null";
          sort-by-number = true;
          active-only = false;
        };
        
        "custom/spotify" = {
          exec = "~/.config/waybar/mediaplayer.py --player spotify";
          format = "{}  ";
          return-type = "json";
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
        };
        
        "clock#date" = {
          format = "{:%b %d %H:%M}";
          tooltip-format = "<span font='FiraCode Nerd Font Propo 14'>{calendar}</span>";
          today-format = "<b>{}</b>";
          tooltip = true;
        };
        
        battery = {
          interval = 2;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          tooltip = true;
          tooltip-format = "{timeTo} • {capacity}%";
        };
        
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click = "wofi-bluetooth";
        };
        
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = ["󰃞" "󰃟" "󰃠"];
          on-scroll-up = "brightnessctl -d intel_backlight s +5%";
          on-scroll-down = "brightnessctl -d intel_backlight s 5%-";
          tooltip = true;
          tooltip-format = "Brightness: {percent}%";
        };
        
        wireplumber = {
          signal = 8;  # Signal for refresh
          interval = "once";  # Only update on signal
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && pkill -RTMIN+8 waybar";
          format = "{icon} {volume}%";
          format-muted = "󰖁 ";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "󰋋";
            hands-free = "󰋋";
            headset = "󰋋";
            phone = "";
            portable = "";
            car = "";
            default = ["󰕿" "󰖀" "󰕾"];
          };
        };
        
        tray = {
          icon-size = 15;
          spacing = 5;
        };
        
        "custom/power" = {
          format = " 󰐥 ";
          tooltip = false;
          on-click = "wlogout";
        };
      };
    };
    
    style = ''
      * {
        font-family: "InterVariable Nerd Font", "Inter", "FiraCode Nerd Font Propo", Roboto, Helvetica, Arial, sans-serif;
        font-size: 18px;
        font-weight: 800;
        margin: 0;
        padding: 0;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      * {
        border: none;
        border-radius: 3px;
        min-height: 0;
        margin: 0.1em 0.2em 0.1em 0.2em;
      }

      #waybar {
        background-color: rgba(26, 27, 38, 0.85);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-radius: 0px;
        margin: 0px;
        padding: 0px 0;
        min-height: 30px;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces button {
        padding: 3px 5px;
        margin: 3px 5px;
        border-radius: 6px;
        color: #d8dee9;
        background-color: transparent;
        transition: all 0.3s ease-in-out;
        font-size: 13px;
      }

      #workspaces button.active {
        color: #d8dee9;
        background: rgba(2, 89, 57, 0.6);
      }

      #workspaces button:hover {
        background: rgba(51, 51, 51, 0.6);
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #workspaces {
        background-color: transparent;
        border-radius: 0px;
        padding: 3px 6px;
      }

      #window {
        background-color: transparent;
        font-size: 15px;
        font-weight: 800;
        color: #d8dee9;
        border-radius: 0px;
        padding: 3px 6px;
        margin: 2px;
        opacity: 1;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #mode,
      #idle_inhibitor,
      #mpd,
      #bluetooth,
      #custom-hyprPicker,
      #custom-power-menu,
      #custom-spotify,
      #custom-launcher,
      #custom-power,
      #custom-pacman,
      #custom-screenshot_t,
      #custom-storage,
      #tray {
        background-color: transparent;
        border-radius: 0px;
        padding: 3px 6px;
        margin: 2px;
      }

      #custom-power {
        background-color: transparent;
        color: #00aeff;
      }

      #tray {
        background-color: transparent;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }
    '';
  };
  
  };
}