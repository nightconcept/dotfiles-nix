{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    
    # Using Tokyo Night theme from alacritty-theme package
    theme = "tokyo_night";
    
    settings = {
      # Font configuration
      font = {
        normal = {
          family = "FiraMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "FiraMono Nerd Font";
          style = "Bold Italic";
        };
        size = 14.0;
      };

      # Window configuration
      window = {
        padding = {
          x = 2;
          y = 2;
        };
        decorations = "Full";
        opacity = 0.97;
        dynamic_title = true;
      };

      # Scrolling
      scrolling = {
        history = 7000;
        multiplier = 3;
      };

      # Mouse configuration
      mouse = {
        hide_when_typing = false;
      };

      # Selection
      selection = {
        save_to_clipboard = true;
      };

      # Terminal settings
      terminal = lib.mkIf pkgs.stdenv.isDarwin {
        shell = {
          program = "/bin/zsh";
          args = [ "-l" ];
        };
      };

      # Key bindings - coordinated with Aerospace, Zellij, and Neovim
      keyboard.bindings = [
        # Terminal-level operations
        { key = "N"; mods = "Command"; action = "CreateNewWindow"; }
        { key = "W"; mods = "Command"; action = "Quit"; }
        { key = "Return"; mods = "Command"; action = "ToggleFullscreen"; }
        
        # Scrolling
        { key = "K"; mods = "Command"; action = "ClearLogNotice"; }
        { key = "K"; mods = "Command|Shift"; chars = "\\u000c"; } # Clear screen
        { key = "PageUp"; mods = "Shift"; action = "ScrollPageUp"; }
        { key = "PageDown"; mods = "Shift"; action = "ScrollPageDown"; }
        { key = "Home"; mods = "Shift"; action = "ScrollToTop"; }
        { key = "End"; mods = "Shift"; action = "ScrollToBottom"; }
        
        # Font size controls
        { key = "Plus"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        
        # Copy/Paste
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "V"; mods = "Command"; action = "Paste"; }
        
        # Vi Mode
        { key = "Space"; mods = "Control|Shift"; action = "ToggleViMode"; }
      ];
    };
  };
}