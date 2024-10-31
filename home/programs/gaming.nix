{pkgs, ...}: {
  home.packages = with pkgs; [
    #lact
    protonup-qt
  ];
}
