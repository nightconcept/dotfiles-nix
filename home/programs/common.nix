{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    bat
    btop
    claude-code
    delta
    desktop-file-utils
    devenv
    duf
    eza
    fastfetch
    gemini-cli
    gnupg
    lazygit
    lua51Packages.lua
    ncdu
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
