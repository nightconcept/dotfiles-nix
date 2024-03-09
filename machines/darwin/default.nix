{ inputs, pkgs, lib, ... }:
{
  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "danny" ];
    gc = {
      automatic = true;
      user = "danny";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;

    casks = [
      "calibre"
      "eloston-chromium"
      "ferdium"
      "fig"
      "firefox"
      "github"
      "hiddenbar"
      "libreoffice"
      "mos"
      "nomachine"
      "notunes"
      "raycast"
      "rectangle"
      "spotify"
      "stretchly"
      "the-unarchiver"
      "typora"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "zoom"
    ];
  };

  services.nix-daemon.enable = true;

  programs.zsh = {
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "zsh-users/zsh-history-substring-search"; }
      ];
    };
  };

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

  system.stateVersion = 4;

}