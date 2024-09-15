{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
    delta
    duf
    eza
    fd
    fzf
    gh
    git-crypt
    ncdu
    neovim
    nmap
    poetry
    rsync
    wget
    zip
  ];
}
