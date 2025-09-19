# Desktop configuration for GUI environments
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
    ../../modules/home
    ../desktops/hyprland
  ];

  modules.home.programs = {
    gaming.enable = true;
    spotify.enable = true;
    wezterm.enable = true;
    xdg.enable = true;
    shell = {
      fish.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };

  modules.home.themes.stylix.enable = true;

  # Stylix theming configuration
  stylix = {
    enable = true;
    
    # Use Tokyo Night theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    
    # Use the laptop wallpaper
    image = ../../wallpaper/laptop.jpg;
    
    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        applications = 11;
        desktop = 10;
        popups = 11;
        terminal = 11;
      };
    };
    
    # Cursor theme - using default Adwaita
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
    
    # Enable styling for applications that need it
    targets = {
      waybar.enable = false;
      wofi.enable = true;  # Enable Stylix theming for wofi
      hyprland.enable = false;
      mako.enable = false;
      alacritty.enable = false;
      swaylock.enable = false;
      gtk.enable = true;  # Enable GTK theming for dark mode
      gnome.enable = false;
      vscode.enable = false;
      firefox.enable = true;  # Let Stylix handle Firefox theming
      spicetify.enable = true;  # Enable Spicetify theming with Tokyo Night colors
      vencord.enable = true;  # Enable Vencord Discord theming with Tokyo Night colors
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    github-desktop
    kdePackages.xdg-desktop-portal-kde
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    obsidian
    uv
    vlc
    vscode
    xdg-utils
  ];

  desktops.hyprland.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-dev-auth" = "github-desktop.desktop";
    };
  };
}
