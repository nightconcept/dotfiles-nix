{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.zellij = {
    enable = true;
    settings = {
      theme = "tokyo-night-dark";
      default_shell = "zsh";
      
      keybinds = {
        normal = {
          # Use Ctrl+t as prefix
          "bind \"Ctrl t\"" = {
            SwitchToMode = "tmux";
          };
        };
        
        tmux = {
          # Pane navigation (vim-style)
          "bind \"h\"" = {
            MoveFocus = "Left";
            SwitchToMode = "Normal";
          };
          "bind \"j\"" = {
            MoveFocus = "Down"; 
            SwitchToMode = "Normal";
          };
          "bind \"k\"" = {
            MoveFocus = "Up";
            SwitchToMode = "Normal";
          };
          "bind \"l\"" = {
            MoveFocus = "Right";
            SwitchToMode = "Normal";
          };
          
          # Pane movement
          "bind \"H\"" = {
            MovePane = "Left";
            SwitchToMode = "Normal";
          };
          "bind \"J\"" = {
            MovePane = "Down";
            SwitchToMode = "Normal"; 
          };
          "bind \"K\"" = {
            MovePane = "Up";
            SwitchToMode = "Normal";
          };
          "bind \"L\"" = {
            MovePane = "Right";
            SwitchToMode = "Normal";
          };
          
          # Pane creation
          "bind \"|\"" = {
            NewPane = "Right";
            SwitchToMode = "Normal";
          };
          "bind \"-\"" = {
            NewPane = "Down";
            SwitchToMode = "Normal";
          };
          
          # Tab operations
          "bind \"n\"" = {
            GoToNextTab = {};
            SwitchToMode = "Normal";
          };
          "bind \"p\"" = {
            GoToPreviousTab = {};
            SwitchToMode = "Normal";
          };
          "bind \"c\"" = {
            NewTab = {};
            SwitchToMode = "Normal";
          };
          
          # Tab switching by number
          "bind \"1\"" = {
            GoToTab = 1;
            SwitchToMode = "Normal";
          };
          "bind \"2\"" = {
            GoToTab = 2;
            SwitchToMode = "Normal";
          };
          "bind \"3\"" = {
            GoToTab = 3;
            SwitchToMode = "Normal";
          };
          "bind \"4\"" = {
            GoToTab = 4;
            SwitchToMode = "Normal";
          };
          "bind \"5\"" = {
            GoToTab = 5;
            SwitchToMode = "Normal";
          };
          "bind \"6\"" = {
            GoToTab = 6;
            SwitchToMode = "Normal";
          };
          "bind \"7\"" = {
            GoToTab = 7;
            SwitchToMode = "Normal";
          };
          "bind \"8\"" = {
            GoToTab = 8;
            SwitchToMode = "Normal";
          };
          "bind \"9\"" = {
            GoToTab = 9;
            SwitchToMode = "Normal";
          };
          
          # Exit tmux mode
          "bind \"Esc\"" = {
            SwitchToMode = "Normal";
          };
        };
      };
      
      ui = {
        pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
      };
      
      plugins = {
        tab-bar = {
          path = "tab-bar";
        };
        status-bar = {
          path = "status-bar";
        };
        strider = {
          path = "strider";
        };
        compact-bar = {
          path = "compact-bar";
        };
      };
      
      themes = {
        tokyo-night-dark = {
          bg = "#1a1b26";
          fg = "#c0caf5";
          red = "#f7768e";
          green = "#9ece6a";
          blue = "#7aa2f7";
          yellow = "#e0af68";
          magenta = "#bb9af7";
          orange = "#ff9e64";
          cyan = "#7dcfff";
          black = "#1a1b26";
          white = "#c0caf5";
        };
      };
    };
  };
}