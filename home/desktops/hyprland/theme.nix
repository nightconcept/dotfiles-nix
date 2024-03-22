{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ... other packages
  ];
  gtk = {
    enable = true;
    font = {
      size = 14;
    }
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-folders;
    };

    theme = {
      name = "Tokyonight-Dark-B-LB";
      package = pkgs.tokyo-night-gtk;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };
}