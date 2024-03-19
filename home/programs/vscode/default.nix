{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions;
        [
          yzhang.markdown-all-in-one
          bbenoist.nix
          emroussel.atomize-atom-one-dark-theme
          eamodio.gitlens
          kamadorueda.alejandra
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
          {
            name = "tokyo-night-henrikvilhelmberglund";
            publisher = "henrikvilhelmberglund";
            version = "1.1.0";
            sha256 = "sha256-WEdmyIwmJ2uigNhksgzr6IH4PIWwthJvX5N1OG3JUZ4=";
          }
        ];
      userSettings = {
        "editor.accessibilitySupport" = "off";
        "editor.guides.bracketPairs" = true;
        "editor.fontFamily" = "'FiraMono Nerd Font', 'FiraCode Nerd Font', Consolas, Meslo, 'monospace', monospace";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = true;
        "editor.rulers" = [
          {
            "color" = "#808080";
            "column" = 100;
          }
        ];
        "editor.tabSize" = 2;
        "editor.wordWrap" = "on";
        "extensions.ignoreRecommendations" = true;
        "git.autofetch" = true;
        "git.defaultBranchName" = "main";
        "gitlens.showWelcomeOnInstall" = false;
        "gitlens.showWhatsNewAfterUpgrades" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.fontSize" = 14;
        "workbench.colorTheme" = "Tokyo Night";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
      };
    };
  };
}
