{
  config,
  lib,
  pkgs,
  ...
}: {
  options.modules.home.programs.rofi = {
    enable = lib.mkEnableOption "rofi application launcher";
  };

  config = lib.mkIf config.modules.home.programs.rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;

      theme = let
        colors = config.lib.stylix.colors;
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg-col = mkLiteral "#${colors.base00}";
          bg-col-light = mkLiteral "#${colors.base01}";
          border-col = mkLiteral "#${colors.base0D}";
          selected-col = mkLiteral "#${colors.base02}";
          blue = mkLiteral "#${colors.base0D}";
          fg-col = mkLiteral "#${colors.base05}";
          fg-col2 = mkLiteral "#${colors.base06}";
          grey = mkLiteral "#${colors.base03}";

          width = 600;
          font = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.applications}";
        };

        "element-text, element-icon, mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "window" = {
          height = mkLiteral "360px";
          border = mkLiteral "3px";
          border-color = mkLiteral "@border-col";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "8px";
        };

        "mainbox" = {
          background-color = mkLiteral "@bg-col";
        };

        "inputbar" = {
          children = map mkLiteral ["prompt" "entry"];
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "5px";
          padding = mkLiteral "2px";
        };

        "prompt" = {
          background-color = mkLiteral "@blue";
          padding = mkLiteral "6px";
          text-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "3px";
          margin = mkLiteral "20px 0px 0px 20px";
        };

        "textbox-prompt-colon" = {
          expand = false;
          str = ":";
        };

        "entry" = {
          padding = mkLiteral "6px";
          margin = mkLiteral "20px 0px 0px 10px";
          text-color = mkLiteral "@fg-col";
          background-color = mkLiteral "@bg-col";
        };

        "listview" = {
          border = mkLiteral "0px 0px 0px";
          padding = mkLiteral "6px 0px 0px";
          margin = mkLiteral "10px 0px 0px 20px";
          columns = 2;
          lines = 5;
          background-color = mkLiteral "@bg-col";
        };

        "element" = {
          padding = mkLiteral "5px";
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@fg-col";
        };

        "element-icon" = {
          size = mkLiteral "25px";
        };

        "element selected" = {
          background-color = mkLiteral "@selected-col";
          border = mkLiteral "0px 0px 0px 2px";
          border-color = mkLiteral "@blue";
        };

        "mode-switcher" = {
          spacing = 0;
        };

        "button" = {
          padding = mkLiteral "10px";
          background-color = mkLiteral "@bg-col-light";
          text-color = mkLiteral "@grey";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.5";
        };

        "button selected" = {
          background-color = mkLiteral "@bg-col";
          text-color = mkLiteral "@blue";
        };

        "message" = {
          background-color = mkLiteral "@bg-col-light";
          margin = mkLiteral "2px";
          padding = mkLiteral "2px";
          border-radius = mkLiteral "5px";
        };

        "textbox" = {
          padding = mkLiteral "6px";
          margin = mkLiteral "20px 0px 0px 20px";
          text-color = mkLiteral "@blue";
          background-color = mkLiteral "@bg-col-light";
        };
      };
    };
  };
}