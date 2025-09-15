{
  config,
  lib,
  pkgs,
  ...
}: {
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
        spacing = 5;
        
        margin-left = 10;
        margin-bottom = 0;
        margin-right = 10;
        
        modules-left = [
          "hyprland/workspaces"
          "temperature"
          "custom/spotify"
        ];
        
        modules-center = [
          "clock#date"
          "custom/weather"
        ];
        
        modules-right = [
          "backlight"
          "custom/storage"
          "memory"
          "cpu"
          "battery"
          "wireplumber"
          "custom/screenshot_t"
          "tray"
          "custom/power"
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
        
        temperature = {
          interval = 4;
          critical-threshold = 80;
          format-critical = "  {temperatureC}°C";
          format = "{icon}  {temperatureC}°C";
          format-icons = ["" "" ""];
          max-length = 7;
          min-length = 7;
          on-click = "xsensors";
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
          format = "󰥔  {:%H:%M \n %e %b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          today-format = "<b>{}</b>";
        };
        
        "custom/weather" = {
          format = "{}";
          format-alt = "{alt}: {}";
          format-alt-click = "click-right";
          interval = 3600;
          exec = "curl -s 'https://wttr.in/?format=1'";
          exec-if = "ping wttr.in -c1";
        };
        
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-alt = "{percent}% {icon}";
          format-alt-click = "click-right";
          format-icons = ["" ""];
          on-scroll-down = "brightnessctl s 5%-";
          on-scroll-up = "brightnessctl s +5%";
        };
        
        "custom/storage" = {
          format = " {}";
          format-alt = "{percentage}% ";
          format-alt-click = "click-right";
          return-type = "json";
          interval = 60;
          exec = "~/.config/waybar/modules/storage.sh";
        };
        
        memory = {
          interval = 30;
          format = "  {used:0.2f} / {total:0.0f} GB";
          on-click = "alacritty -e btop";
        };
        
        cpu = {
          interval = 1;
          format = "{max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
          max-length = 13;
          min-length = 13;
        };
        
        battery = {
          interval = 2;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = ["" "" "" "" ""];
        };
        
        wireplumber = {
          on-click = "pavucontrol";
          on-click-right = "amixer sset Master toggle 1>/dev/null";
          format = "<span foreground='#fab387'>{icon}</span>  {volume}%";
          format-muted = " ";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = " ";
            hands-free = " ";
            headset = " ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [" " " " " "];
          };
        };
        
        "custom/screenshot_t" = {
          format = " ";
          on-click = "~/.config/hypr/scripts/screenshot_full";
          on-click-right = "~/.config/hypr/scripts/screenshot_area";
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
        font-family: "Fira Sans Semibold", "Font Awesome 6 Free", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        font-size: 14px;
        font-weight: 900;
        margin: 0;
        padding: 0;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      * {
        border: none;
        border-radius: 3px;
        min-height: 0;
        margin: 0.2em 0.3em 0.2em 0.3em;
      }

      #waybar {
        background-color: transparent;
        color: #ffffff;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-radius: 0px;
        margin: 0px 0px;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces button {
        padding: 3px 5px;
        margin: 3px 5px;
        border-radius: 6px;
        color: #d8dee9;
        background-color: #111827;
        transition: all 0.3s ease-in-out;
        font-size: 13px;
      }

      #workspaces button.active {
        color: #d8dee9;
        background: #025939;
      }

      #workspaces button:hover {
        background: #333333;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #workspaces {
        background-color: #111827;
        border-radius: 14px;
        padding: 3px 6px;
      }

      #window {
        background-color: #111827;
        font-size: 15px;
        font-weight: 800;
        color: #d8dee9;
        border-radius: 14px;
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
      #custom-weather,
      #custom-weather.severe,
      #custom-weather.sunnyDay,
      #custom-weather.clearNight,
      #custom-weather.cloudyFoggyDay,
      #custom-weather.cloudyFoggyNight,
      #custom-weather.rainyDay,
      #custom-weather.rainyNight,
      #custom-weather.showyIcyDay,
      #custom-weather.snowyIcyNight,
      #custom-weather.default,
      #custom-launcher,
      #custom-power,
      #custom-pacman,
      #custom-screenshot_t,
      #custom-storage,
      #tray {
        background-color: #111827;
        border-radius: 14px;
        padding: 3px 6px;
        margin: 2px;
      }

      #custom-power {
        background-color: #111827;
        color: #00aeff;
      }

      #tray {
        background-color: #111827;
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
  
  # Copy supporting scripts
  home.file.".config/waybar/mediaplayer.py" = {
    source = ../../waybar/mediaplayer.py;
    executable = true;
  };
  
  home.file.".config/waybar/waybar.sh" = {
    source = ../../waybar/waybar.sh;
    executable = true;
  };
  
  home.file.".config/waybar/modules/storage.sh" = {
    source = ../../waybar/modules/storage.sh;
    executable = true;
  };
}