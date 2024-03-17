{ inputs, lib, pkgs,  ... }: 
{
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

    alt-tab-macos
    discord
    hugo
    karabiner-elements
    mpv
    obsidian
  ];

  imports = [
      ../../config/zsh
      ../../config/vscode
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/Users/danny";
    stateVersion = "23.11";
  };

  }