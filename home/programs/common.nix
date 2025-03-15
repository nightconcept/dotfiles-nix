{pkgs, ...}: {
  home.packages = with pkgs; [
    bat
    btop
    delta
    deno
    duf
    eza
    gh
    nmap
    neovim
    poetry
    rsync
    wget
    zip
  ];
}
