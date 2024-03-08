{ inputs, pkgs, lib, ... }:
{
  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "danny" ];
    gc = {
      automatic = true;
      dates = "weekly";
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

#   homebrew = {
#     enable = true;
#     onActivation = {
#       autoUpdate = true;
#       cleanup = "zap";
#       upgrade = true;
#     };
#     brewPrefix = "/opt/homebrew/bin";
#     caskArgs = {
#       no_quarantine = true;
#     };

#     casks = [
#       "discord"
#       "notion"
#       "telegram"
#       "spotify"
#       "signal"
#       "karabiner-elements"
#       "grid"
#       "scroll-reverser"
#       "topnotch"
#       "bambu-studio"
#       "monitorcontrol"
#     ];
#   };

  services.nix-daemon.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
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