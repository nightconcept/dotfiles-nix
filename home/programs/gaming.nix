{pkgs, ...}: {
  home.packages = with pkgs; [
    corectrl
    discord
    protonup-qt
    steam
  ];
}
