{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./bootloader.nix
    ./hardware.nix
    ./fonts.nix
    ./locale.nix
    ./network.nix
    ./opengl.nix
    ./nix.nix
    ./sound.nix
    ./users.nix
  ];

  # System available packages
  environment.systemPackages = with pkgs; [
    bat
    btop
    cifs-utils
    curl
    gcc
    gh
    git
    wget
    vim
    wget
    zsh
  ];

  services = {
    fwupd.enable = true;
    gvfs.enable = true;
  };

  # Set zsh defaults
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };
}
