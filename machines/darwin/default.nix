{ inputs, pkgs, lib, ... }:
{

  nix.extraOptions = ''
  auto-optimise-store = true
  experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
  extra-platforms = x86_64-darwin aarch64-darwin
  '';

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

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    fzf
    duf
    vim
    speedtest-cli
    wget
    curl
    nmap
    rsync
    trash-cli
    tldr
    btop
    ncdu
    dosfstools
    mtools
    p7zip
    unzip
    zip
    zsh
    stow
    tmux
    neovim
    fastfetch
    git
    lazygit
    eza
    zoxide
    thefuck
    fd
    fnm
  ];

  system.stateVersion = 4;

}