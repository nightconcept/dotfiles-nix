{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./direnv.nix
    ./git.nix
    ./ssh.nix
    ./vscode.nix
    ./wezterm
    ./zsh
  ];

  home.packages = with pkgs; [
    delta
    duf
    eza
    fd
    fzf
    git-crypt
    ncdu
    neovim
    nmap
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
    hexchat
    libreoffice-fresh
    mpv
    nomachine-client
    pavucontrol
    protonup-qt
    spotify
    ungoogled-chromium
    zoom
  ];
}
