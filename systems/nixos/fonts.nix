{
  config,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      fira
      fira-mono
      fira-go
      fira-code-symbols
      joypixels
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      source-serif
      work-sans
      (callPackage ./pkgs/inter-nerd-font.nix {})
    ];
    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = ["Source Serif"];
        sansSerif = ["Work Sans" "Fira Sans" "FiraGO"];
        monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
        emoji = ["Joypixels" "Noto Color Emoji"];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };
}
