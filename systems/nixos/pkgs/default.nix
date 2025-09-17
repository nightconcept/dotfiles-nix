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
    gnupg
    home-manager
    uv
    vim
    wget
    fish
  ];

  # Enable fish system-wide
  programs.fish = {
    enable = true;
  };
}
