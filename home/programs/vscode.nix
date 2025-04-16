{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs = {
    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.vscode-extensions;
          [
            yzhang.markdown-all-in-one
            bbenoist.nix
            eamodio.gitlens
            kamikillerto.vscode-colorize
            pkief.material-icon-theme
            ms-python.python
            ms-vscode-remote.remote-ssh-edit
            svelte.svelte-vscode
            elixir-lsp.vscode-elixir-ls
            ms-vscode-remote.remote-wsl
            tamasfe.even-better-toml
            styled-components.vscode-styled-components
            davidanson.vscode-markdownlint
            shd101wyy.markdown-preview-enhanced
            yoavbls.pretty-ts-errors
            astro-build.astro-vscode
            bradlc.vscode-tailwindcss
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "where-am-i";
              publisher = "antfu";
              version = "0.2.0";
              sha256 = "sha256-M9TCILD6KKLHCDBP0mBR5soeYb2MFuBAmyKPlKbl1tg=";
            }
            {
              name = "tokyo-night-henrikvilhelmberglund";
              publisher = "henrikvilhelmberglund";
              version = "1.1.0";
              sha256 = "sha256-WEdmyIwmJ2uigNhksgzr6IH4PIWwthJvX5N1OG3JUZ4=";
            }
            {
              name = "remote-explorer";
              publisher = "ms-vscode";
              version = "0.5.2025021709";
              sha256 = "sha256-tCNkC7qa59oL9TXA+OKN0Tq5wl0TOLJhHpiKRLmMlgo=";
            }
            {
              name = "remote-ssh";
              publisher = "ms-vscode-remote";
              version = "0.120.2025040915";
              sha256 = "sha256-XW7BiUtqFH758I5DDRU2NPdESJC6RfTDAuUA4myY734=";
            }
            {
              name = "roo-cline";
              publisher = "rooveterinaryinc";
              version = "3.12.1";
              sha256 = "sha256-3wkhCcpljNJMHpLDPs2lIpP5LufRxyUIlW8Dkzqlar4=";
            }
          ];
        userSettings = {
          "chat.commandCenter.enabled" = false;
          "colorize.languages" = [
            "nix"
            "rasi"
          ];
          "editor.accessibilitySupport" = "off";
          "editor.guides.bracketPairs" = true;
          "editor.fontFamily" = "'FiraCode Nerd Font', Consolas, Meslo, 'monospace', monospace";
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
          "git.confirmSync" = false;
          "git.defaultBranchName" = "main";
          "gitlens.showWhatsNewAfterUpgrades" = false;
          "svelte.enable-ts-plugin" = true;
          "telemetry.telemetryLevel" = "off";
          "terminal.integrated.fontSize" = 14;
          "update.mode" = "none";
          "window.zoomLevel" = 1;
          "workbench.colorTheme" = "Tokyo Night";
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.startupEditor" = "none";
        };
      };
    };
  };
}
