{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = false;
    };
    settings = [
      {
        layer = "top";
        position = "top";
        height = 50;
        spacing = 5;

        modules-left = [
          "hyprland/workspaces"
          "tray"
        ];
        modules-right = [
          "idle_inhibitor"
          "battery"
          "pulseaudio"
          "network"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          sort-by-number = true;
          active-only = false;
          format-icons = {
            "1" = "  ";
            "2" = " 󰎞 ";
            "3" = " 󰲌 ";
            "4" = "  ";
            "5" = "  ";
            "6" = " 󰺵 ";
            "7" = "  ";
            urgent = "  ";
            focused = "  ";
            default = "  ";
          };
          on-click = "activate";
        };
        clock = {
          format = "{:%a %d %b %I:%M %p}";
          interval = 1;
          tooltip-format = "{:%A, %B %d, %Y}";
          calendar = {
            mode = "month";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
          };
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "  ";
            deactivated = "  ";
          };
        };
        battery = {
          states = {
            good = 80;
            warning = 50;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-alt = "{time}";
          format-charging = "  {capacity}%";
          format-icons = ["󰁻 " "󰁽 " "󰁿 " "󰂁 " "󰂂 "];
        };
        network = {
          interval = 1;
          format-wifi = " ";
          format-ethernet = "󰈀";
          format-disconnected = "󱚵";
          tooltip-format = ''
            Network: {essid}
            {ifname}
            {ipaddr}
            {signalstrength}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}
          '';
        };
        pulseaudio = {
          scroll-step = 2;
          format = "{icon} {volume}%";
          format-bluetooth = " {icon} {volume}%";
          format-muted = "󰖁";
          format-icons = {
            headphone = "";
            headset = "";
            default = ["", "", "󰕾"];
          };
          "tooltip-format" = "{volume}% volume";
        };
        tray = {
          icon-size = 16;
          spacing = 10;
        };
      }
    ];

    style = builtins.readFile ./style.css;
  };
}
