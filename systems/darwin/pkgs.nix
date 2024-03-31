{
  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    gcc
    gh
    git
    home-manager
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
