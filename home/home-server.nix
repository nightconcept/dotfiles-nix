{ inputs, lib, pkgs,  ... }: 
{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = ''
      warn-dirty = false
    '';
  };

  home.packages = with pkgs; [
    btop
    duf
    eza
    fastfetch
    fd
    fnm
    fzf
    git
    gh
    lazydocker
    lazygit
    ncdu
    neovim
    nmap
    pyenv
    rsync
    speedtest-cli
    thefuck
    tldr
    tmux
    trash-cli
    vim
    wget
    zip
    zoxide
  ];

  imports = [
      ./config/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };


  }