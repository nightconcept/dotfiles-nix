{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    bat
    btop
    delta
    desktop-file-utils
    devenv
    duf
    eza
    fastfetch
    gh
    gnupg
    lazygit
    lua51Packages.lua
    ncdu
    neovim
    nix-prefetch-github
    nmap
    nodejs_22
    rsync
    uv
    vim
    wget
    zip
    zoxide
  ];
}
