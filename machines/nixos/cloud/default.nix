
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "cloud"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "DroidSansMono" ]; })
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
  
  users.users.danny = {
    isNormalUser = true;
    description = "Danny";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    acpi
    tlp
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
    pavucontrol
    audacious
    bandwhich
    mpv
    libreoffice-fresh
    foliate
    discord
    ungoogled-chromium
    calibre
    obsidian
    steam
    evince
    fontconfig
    ferdium
    fnm
    github-desktop
    nomachine-client
    protonup-qt
    spotify
    stretchly
    vscode
    wezterm
    zoom
    hugo
    corectrl
    gcc
    home-manager
    gh
  ];

  # Do not touch
  system.stateVersion = "23.11";

}
