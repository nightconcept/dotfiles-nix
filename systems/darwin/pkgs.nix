{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    gcc
    gh
    git
    gnupg
    home-manager
    netbird
    wget
    vim
    wget
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };
}
