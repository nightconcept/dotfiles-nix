{ inputs, pkgs, lib, ... }:
{
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        bbenoist.nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "solarized-osaka";
        publisher = "sherloach";
        version = "0.1.1";
        sha256 = "sha256-HYkzht8jPYBwE3bHHvyU4amNYunsfayPTWBiBVyY+1g=";
      }
      {
        name = "where-am-i";
        publisher = "antfu";
        version = "0.2.0";
        sha256 = "sha256-M9TCILD6KKLHCDBP0mBR5soeYb2MFuBAmyKPlKbl1tg=";
      }
      {
        name = "material-icon-theme";
        publisher = "PKief";
        version = "4.34.0";
        sha256 = "sha256-xxOEUvMjqJbl8lONB/So2NoIAVPOxysTq2YQY3iHGqo=";
      }
      ];
      userSettings = {
        "workbench.colorTheme" = "Solarized Osaka";
        "editor.fontFamily" = "'FiraMono Nerd Font', 'monospace', monospace";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = false;
        "workbench.iconTheme" = "material-icon-theme";
      };
    };
  };
}