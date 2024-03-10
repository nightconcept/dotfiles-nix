
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    dosfstools
    duf
    eza
    fastfetch
    fd
    fnm
    fzf
    gcc
    gh
    git
    lazygit
    wget
    ncdu
    neovim
    nmap
    pyenv
    rsync
    speedtest-cli
    stow
    thefuck
    tldr
    tmux
    trash-cli
    vim
    wget
    zip
    zoxide
    zsh
  ];
}