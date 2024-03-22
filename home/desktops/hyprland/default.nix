{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./dunst
    ./hyprland
    ./gtk.nix
    ./kanshi.nix
    ./rofi
    ./waybar
    ./wlogout
  ];

  config = {
    home.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

    home.packages = with pkgs; [
      brightnessctl
      grimblast
      pamixer
      wl-clipboard
      # Thunar is very needy and needs all of these and gvfs to get it's full functional powers
      # xfce.thunar
      # xfce.thunar-archive-plugin
      # xfce.thunar-media-tags-plugin
      # xfce.thunar-volman
      # xfce.tumbler
      # xfce.xfconf
      gnome.gnome-power-manager

      gnome.nautilus
      ffmpegthumbnailer # thumbnails
      gnome.nautilus-python # enable plugins
      gst_all_1.gst-libav # thumbnails
      nautilus-open-any-terminal # terminal-context-entry
    ];
  };
}
