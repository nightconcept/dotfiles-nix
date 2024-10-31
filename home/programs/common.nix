{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
    delta
    duf
    eza
    fd
    fzf
    gh
    ncdu
    nmap
    poetry
    rsync
    wget
    zip
  ];
}
