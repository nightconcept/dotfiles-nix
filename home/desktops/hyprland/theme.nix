{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ... other packages
  ];
  gtk = {
    enable = true;
    theme = {
      name = "tokyo-night-gtk_full";
      package = pkgs.tokyo-night-gtk;
    };
  };
}