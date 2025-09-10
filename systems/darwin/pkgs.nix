{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    gcc
    git
    gnupg
    home-manager
    wget
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };
}
