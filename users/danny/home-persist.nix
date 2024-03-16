{ config, pkgs, inputs, ... }:

{ 
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    duf
    eza
    fd
    fnm
    fzf
    lazygit
    ncdu
    neofetch
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
    wget
    zip
    zoxide

    audacious
    bandwhich
    corectrl
    calibre
    discord
    foliate
    hugo
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
    stretchly
    ungoogled-chromium
    vscode
    wezterm
    zoom
  ];

  imports = [
      ../../dots/zsh
      ../../dots/vscode
  ];

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.persistence."/persist/home" = {
    directories = [
      "Downloads"
      "git"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "VirtualBox VMs"
      ".gnupg"
      ".ssh"
      ".nixops"
      ".local/share/keyrings"
      ".local/share/direnv"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
    files = [
      ".screenrc"
    ];
    allowOther = true;
  };
}
