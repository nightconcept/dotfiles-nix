{
  lib,
  pkgs,
  ...
}: {
  programs.aerospace = {
    enable = true;
    userSettings = {
      # Start AeroSpace at login
      start-at-login = true;

      # You can use it to add commands that run after AeroSpace startup.
      after-startup-command = [
        "exec-and-forget /opt/homebrew/bin/borders active_color=0xff7aa2f7 inactive_color=0xff565f89 width=3.0"
      ];

      # Normalizations
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Layout settings
      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Key mapping
      "key-mapping".preset = "qwerty";

      # No workspace change notifications needed for default menu bar

      gaps = {
        inner.horizontal = 15;
        inner.vertical = 15;
        outer.left = 12;
        outer.bottom = 12;
        outer.top = 12; # Space for default macOS menu bar
        outer.right = 12;
      };

      mode.main.binding = {
        # Layout commands
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # Close window
        alt-shift-c = "close";

        # Application launching (keeping cmd for these as they're app shortcuts)
        alt-enter = "exec-and-forget open -n /Applications/WezTerm.app";
        alt-b = "exec-and-forget open -a 'Firefox'";
        alt-f = "exec-and-forget open -a 'Finder'";

        # Navigation - vim-style hjkl
        alt-h = ["focus left" "move-mouse window-lazy-center"];
        alt-j = ["focus down" "move-mouse window-lazy-center"];
        alt-k = ["focus up" "move-mouse window-lazy-center"];
        alt-l = ["focus right" "move-mouse window-lazy-center"];

        # Move windows
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # Window resizing
        alt-shift-minus = "resize smart -50";
        alt-shift-equal = "resize smart +50";

        # Workspace navigation - full 1-10 support
        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";
        cmd-0 = "workspace 10";

        # Move window to workspace
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

        # Workspace switching
        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # Tiling controls
        alt-shift-f = "fullscreen";
        alt-shift-w = "layout floating tiling";
        alt-shift-s = "layout v_accordion";
        alt-shift-t = "layout h_accordion";
        alt-shift-e = "layout tiles horizontal vertical";
        alt-shift-d = "resize width 1280";

        # Mode switching
        alt-shift-semicolon = "mode service";
        alt-shift-g = "mode lock";
      };

      mode.service.binding = {
        r = "reload-config";
        f = ["flatten-workspace-tree" "mode main"];
        backspace = ["close-all-windows-but-current" "mode main"];

        alt-shift-h = ["join-with left" "mode main"];
        alt-shift-j = ["join-with down" "mode main"];
        alt-shift-k = ["join-with up" "mode main"];
        alt-shift-l = ["join-with right" "mode main"];

        enter = "mode main";
        esc = "mode main";
      };

      mode.lock.binding = {
        enter = "mode main";
        esc = "mode main";
      };

      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
    };
  };
}
