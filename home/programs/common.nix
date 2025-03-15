{pkgs, ...}: {
  home.packages = with pkgs; [
    bat
    btop
    delta
    deno
    duf
    eza
    fd
    fzf
    gh
    nmap
    neovim
    poetry
    rsync
    wget
    zip
  ];
}
