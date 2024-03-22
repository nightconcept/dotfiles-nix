{
  config,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      (
        nerdfonts.override
        {
          fonts = [
            "FiraCode"
            "FiraMono"
            "SourceCodePro"
            "Ubuntu"
            "UbuntuMono"
          ];
        }
      )
      fira
      fira-go
      fira-code-symbols
      joypixels
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-serif
      work-sans
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
