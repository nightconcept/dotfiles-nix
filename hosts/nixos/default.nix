{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./users.nix
  ];

  # Bootloader settings
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = ["danny"];
    settings.experimental-features = ["nix-command" "flakes"];
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      warn-dirty = false
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;

  # Networking settings
  networking.networkmanager.enable = true;

  # Time and locale settings
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

  # Printing settings
  services.printing.enable = true;

  # Sound settings
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      (
        nerdfonts.override
        {
          fonts = [
            "DroidSansMono"
            "FiraCode"
            "FiraMono"
            "Hack"
            "Inconsolata"
            "Noto"
            "SourceCodePro"
            "Ubuntu"
          ];
        }
      )
    ];
  };

  # Set zsh defaults
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };

  # Network mounts
  # TODO: Relies on <SERVER>-secrets in /etc/nixos for now, change it later
  # Source: https://nixos.wiki/wiki/Samba#CIFS_mount_configuration
  fileSystems."/mnt/gawain" = {
    device = "//terra/gawain";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/terra-secrets,uid=1000,gid=100"];
  };

  fileSystems."/mnt/lancelot" = {
    device = "//terra/lancelot";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/terra-secrets,uid=1000,gid=100"];
  };

  fileSystems."/mnt/titan" = {
    device = "//mog/titan";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/mog-secrets,uid=1000,gid=100"];
  };

  # Automount USB drives
  services.udev.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem",
    RUN{program} += "${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media
  '';
}
