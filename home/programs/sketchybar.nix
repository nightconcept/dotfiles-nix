{
  lib,
  pkgs,
  ...
}: {
  programs.sketchybar = {
    enable = true;
    config = ''
      #!/bin/bash
      
      # Simplified SketchyBar configuration - Tokyo Night theme
      # Color Palette
      BLACK=0xff1a1b26
      WHITE=0xffc0caf5
      RED=0xfff7768e
      GREEN=0xff9ece6a
      BLUE=0xff7aa2f7
      YELLOW=0xffe0af68
      ORANGE=0xffff9e64
      MAGENTA=0xffbb9af7
      PURPLE=0xff9d7cd8
      CYAN=0xff7dcfff
      GREY=0xff565f89
      DARK_GREY=0xff32344a
      
      # Background colors
      BAR_COLOR=0xee1a1b26
      ITEM_BG_COLOR=0xaa24283b
      ACCENT_COLOR=$BLUE

      # Bar configuration - full width
      sketchybar --bar height=32 \
                       position=top \
                       color=$BAR_COLOR \
                       corner_radius=0 \
                       margin=0 \
                       padding_left=10 \
                       padding_right=10

      # Default item style - using Fira Mono Nerd Font
      sketchybar --default icon.font="FiraMono Nerd Font:Bold:14.0" \
                           icon.color=$WHITE \
                           icon.padding_left=4 \
                           icon.padding_right=4 \
                           label.font="FiraMono Nerd Font:Bold:14.0" \
                           label.color=$WHITE \
                           label.padding_left=4 \
                           label.padding_right=4 \
                           background.color=$ITEM_BG_COLOR \
                           background.corner_radius=6

      # Add aerospace workspace change event
      sketchybar --add event aerospace_workspace_change

      # Aerospace workspace indicators with click functionality and highlighting
      sketchybar --add item space.1 left \
                 --subscribe space.1 aerospace_workspace_change \
                 --set space.1 label="1" \
                               label.drawing=on \
                               label.color=$GREY \
                               label.font="FiraMono Nerd Font:Bold:16.0" \
                               label.padding_left=8 \
                               label.padding_right=8 \
                               icon.drawing=off \
                               background.color=$ITEM_BG_COLOR \
                               background.corner_radius=6 \
                               background.height=24 \
                               background.drawing=off \
                               click_script="aerospace workspace 1" \
                               script='if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "1" ]; then sketchybar --set space.1 background.drawing=on label.color='$WHITE'; else sketchybar --set space.1 background.drawing=off label.color='$GREY'; fi'

      sketchybar --add item space.2 left \
                 --subscribe space.2 aerospace_workspace_change \
                 --set space.2 label="2" \
                               label.drawing=on \
                               label.color=$GREY \
                               label.font="FiraMono Nerd Font:Bold:16.0" \
                               label.padding_left=8 \
                               label.padding_right=8 \
                               icon.drawing=off \
                               background.color=$ITEM_BG_COLOR \
                               background.corner_radius=6 \
                               background.height=24 \
                               background.drawing=off \
                               click_script="aerospace workspace 2" \
                               script='if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "2" ]; then sketchybar --set space.2 background.drawing=on label.color='$WHITE'; else sketchybar --set space.2 background.drawing=off label.color='$GREY'; fi'

      sketchybar --add item space.3 left \
                 --subscribe space.3 aerospace_workspace_change \
                 --set space.3 label="3" \
                               label.drawing=on \
                               label.color=$GREY \
                               label.font="FiraMono Nerd Font:Bold:16.0" \
                               label.padding_left=8 \
                               label.padding_right=8 \
                               icon.drawing=off \
                               background.color=$ITEM_BG_COLOR \
                               background.corner_radius=6 \
                               background.height=24 \
                               background.drawing=off \
                               click_script="aerospace workspace 3" \
                               script='if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "3" ]; then sketchybar --set space.3 background.drawing=on label.color='$WHITE'; else sketchybar --set space.3 background.drawing=off label.color='$GREY'; fi'

      sketchybar --add item space.4 left \
                 --subscribe space.4 aerospace_workspace_change \
                 --set space.4 label="4" \
                               label.drawing=on \
                               label.color=$GREY \
                               label.font="FiraMono Nerd Font:Bold:16.0" \
                               label.padding_left=8 \
                               label.padding_right=8 \
                               icon.drawing=off \
                               background.color=$ITEM_BG_COLOR \
                               background.corner_radius=6 \
                               background.height=24 \
                               background.drawing=off \
                               click_script="aerospace workspace 4" \
                               script='if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "4" ]; then sketchybar --set space.4 background.drawing=on label.color='$WHITE'; else sketchybar --set space.4 background.drawing=off label.color='$GREY'; fi'

      sketchybar --add item space.5 left \
                 --subscribe space.5 aerospace_workspace_change \
                 --set space.5 label="5" \
                               label.drawing=on \
                               label.color=$GREY \
                               label.font="FiraMono Nerd Font:Bold:16.0" \
                               label.padding_left=8 \
                               label.padding_right=8 \
                               icon.drawing=off \
                               background.color=$ITEM_BG_COLOR \
                               background.corner_radius=6 \
                               background.height=24 \
                               background.drawing=off \
                               click_script="aerospace workspace 5" \
                               script='if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "5" ]; then sketchybar --set space.5 background.drawing=on label.color='$WHITE'; else sketchybar --set space.5 background.drawing=off label.color='$GREY'; fi'
      
      # Simple separator
      sketchybar --add item separator_left left \
                 --set separator_left icon="|" \
                                      icon.color=$DARK_GREY \
                                      background.drawing=off

      # Centered date/time with requested format
      sketchybar --add item datetime center \
                 --set datetime label="$(date '+%a %b %-d %H:%M')" \
                               label.color=$WHITE \
                               label.font="FiraMono Nerd Font:Bold:14.0" \
                               background.drawing=off \
                               update_freq=30 \
                               script='sketchybar --set datetime label="$(date "+%a %b %-d %H:%M")"'

      # WiFi indicator with signal strength (no hover)
      sketchybar --add item wifi right \
                 --set wifi icon="󰤨" \
                               icon.color=$CYAN \
                               icon.font="FiraMono Nerd Font:Bold:16.0" \
                               background.drawing=off \
                               icon.padding_left=6 \
                               icon.padding_right=6 \
                               update_freq=10 \
                               script='
                                 WIFI_STATE=$(networksetup -getairportpower en0 2>/dev/null | grep "On" || echo "Off")
                                 if [[ "$WIFI_STATE" == *"On"* ]]; then
                                   RSSI=$(system_profiler SPAirPortDataType 2>/dev/null | grep "Signal / Noise" | awk "{print \$4}" | head -1 || echo "-50")
                                   if [[ $RSSI -gt -30 ]]; then
                                     sketchybar --set wifi icon="󰤨" icon.color='$CYAN'
                                   elif [[ $RSSI -gt -50 ]]; then
                                     sketchybar --set wifi icon="󰤥" icon.color='$CYAN'
                                   elif [[ $RSSI -gt -70 ]]; then
                                     sketchybar --set wifi icon="󰤢" icon.color='$YELLOW'
                                   else
                                     sketchybar --set wifi icon="󰤟" icon.color='$RED'
                                   fi
                                 else
                                   sketchybar --set wifi icon="󰤮" icon.color='$GREY'
                                 fi
                               '

      # Bluetooth indicator (read-only) with faster updates
      sketchybar --add item bluetooth right \
                 --set bluetooth icon="󰂯" \
                               icon.color=$BLUE \
                               icon.font="FiraMono Nerd Font:Bold:16.0" \
                               background.drawing=off \
                               icon.padding_left=6 \
                               icon.padding_right=6 \
                               update_freq=3 \
                               script='
                                 # Use multiple methods to check Bluetooth status for better reliability
                                 BT_STATE1=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null || echo "0")
                                 BT_STATE2=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -q "Bluetooth Power: On" && echo "1" || echo "0")
                                 BT_STATE3=$(blueutil -p 2>/dev/null || echo "0")
                                 
                                 # Use the most reliable indicator (prefer blueutil if available, then system_profiler, then defaults)
                                 if command -v blueutil >/dev/null 2>&1; then
                                   BT_STATE="$BT_STATE3"
                                 elif [[ "$BT_STATE2" == "1" ]]; then
                                   BT_STATE="1"
                                 else
                                   BT_STATE="$BT_STATE1"
                                 fi
                                 
                                 if [[ "$BT_STATE" == "1" ]]; then
                                   sketchybar --set bluetooth icon="󰂯" icon.color='$BLUE'
                                 else
                                   sketchybar --set bluetooth icon="󰂲" icon.color='$GREY'
                                 fi
                               ' \
                 --subscribe bluetooth system_woke power_source_change

      # Volume indicator with hover percentage
      sketchybar --add item volume right \
                 --set volume icon="󰕾" \
                               icon.color=$ORANGE \
                               icon.font="FiraMono Nerd Font:Bold:16.0" \
                               label.color=$WHITE \
                               label.font="FiraMono Nerd Font:Bold:14.0" \
                               label.drawing=off \
                               background.drawing=off \
                               icon.padding_left=6 \
                               icon.padding_right=6 \
                               update_freq=5 \
                               script='
                                 if [[ "$SENDER" == "mouse.entered" ]]; then
                                   VOL=$(osascript -e "output volume of (get volume settings)")
                                   sketchybar --set volume label.drawing=on label="$VOL%"
                                 elif [[ "$SENDER" == "mouse.exited" ]]; then
                                   sketchybar --set volume label.drawing=off
                                 else
                                   VOL=$(osascript -e "output volume of (get volume settings)")
                                   MUTED=$(osascript -e "output muted of (get volume settings)")
                                   if [[ "$MUTED" == "true" ]]; then
                                     sketchybar --set volume icon="󰖁" icon.color='$RED'
                                   elif [[ $VOL -gt 66 ]]; then
                                     sketchybar --set volume icon="󰕾" icon.color='$ORANGE'
                                   elif [[ $VOL -gt 33 ]]; then
                                     sketchybar --set volume icon="󰖀" icon.color='$ORANGE'
                                   elif [[ $VOL -gt 0 ]]; then
                                     sketchybar --set volume icon="󰕿" icon.color='$ORANGE'
                                   else
                                     sketchybar --set volume icon="󰖁" icon.color='$GREY'
                                   fi
                                 fi
                               ' \
                 --subscribe volume mouse.entered mouse.exited

      # Battery indicator with hover percentage
      sketchybar --add item battery right \
                 --set battery icon="󰁹" \
                               icon.color=$GREEN \
                               icon.font="FiraMono Nerd Font:Bold:16.0" \
                               label.color=$WHITE \
                               label.font="FiraMono Nerd Font:Bold:14.0" \
                               label.drawing=off \
                               background.drawing=off \
                               icon.padding_left=6 \
                               icon.padding_right=6 \
                               update_freq=30 \
                               script='
                                 if [[ "$SENDER" == "mouse.entered" ]]; then
                                   BATTERY_PERCENT=$(pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1 | sed "s/%//")
                                   sketchybar --set battery label.drawing=on label="''${BATTERY_PERCENT}%"
                                 elif [[ "$SENDER" == "mouse.exited" ]]; then
                                   sketchybar --set battery label.drawing=off
                                 else
                                   BATTERY_PERCENT=$(pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1 | sed "s/%//")
                                   CHARGING=$(pmset -g batt 2>/dev/null | grep -q "AC Power" && echo "true" || echo "false")
                                   
                                   if [[ "$CHARGING" == "true" ]]; then
                                     sketchybar --set battery icon="󰂄" icon.color='$YELLOW'
                                   elif [[ $BATTERY_PERCENT -gt 80 ]]; then
                                     sketchybar --set battery icon="󰁹" icon.color='$GREEN'
                                   elif [[ $BATTERY_PERCENT -gt 60 ]]; then
                                     sketchybar --set battery icon="󰂀" icon.color='$GREEN'
                                   elif [[ $BATTERY_PERCENT -gt 40 ]]; then
                                     sketchybar --set battery icon="󰁾" icon.color='$YELLOW'
                                   elif [[ $BATTERY_PERCENT -gt 20 ]]; then
                                     sketchybar --set battery icon="󰁼" icon.color='$ORANGE'
                                   else
                                     sketchybar --set battery icon="󰁺" icon.color='$RED'
                                   fi
                                 fi
                               ' \
                 --subscribe battery mouse.entered mouse.exited

      # Update all items
      sketchybar --update
      
      echo "SketchyBar simplified configuration loaded..."
    '';
  };
}