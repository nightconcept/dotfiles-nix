{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
    delta
    duf
    eza
    fd
    fzf
    gh
    nmap
    poetry
    rsync
    wget
    zip
  ];
}
