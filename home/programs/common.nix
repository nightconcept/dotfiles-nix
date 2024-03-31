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
    rsync
    wget
    zip
  ];
}
