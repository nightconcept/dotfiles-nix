{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./direnv.nix
    ./git.nix
    ./vscode
    ./wezterm
    ./zsh
  ];

  home.packages = with pkgs; [
    delta
    duf
    eza
    fd
    fnm
    fzf
    git-crypt
    ncdu
    neovim
    nmap
    pyenv
    rsync
    tmux
    trash-cli
    wget
    zip
    zoxide

    audacious
    corectrl
    discord
    foliate
    obsidian
    steam
    evince
    fontconfig
    ferdium
    fnm
    github-desktop
    hexchat
    libreoffice-fresh
    mpv
    nomachine-client
    pavucontrol
    protonup-qt
    spotify
    ungoogled-chromium
    kitty
    zoom
  ];
}
