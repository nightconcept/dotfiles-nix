{
  config,
  pkgs,
  ...
}: {
  # System available packages
  environment.systemPackages = with pkgs; [
    bat
    btop
    cifs-utils
    curl
    gh
    git
    home-manager
    vim
    wget
  ];

  # Enable zsh system-wide
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };
}
