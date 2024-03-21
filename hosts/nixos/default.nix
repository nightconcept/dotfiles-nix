{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./bootloader.nix
    ./fonts.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./sound.nix
    ./users.nix
  ];

  # Printing settings
  services.printing.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        mesa
      ];
    };
  };

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

  # Set zsh defaults
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };

  # Automount USB drives
  services.udev.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem",
    RUN{program} += "${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media
  '';
}
