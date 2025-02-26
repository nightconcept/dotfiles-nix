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
    poetry
    jetbrains.pycharm-community-bin
    rsync
    wget
    zip
  ];
}
