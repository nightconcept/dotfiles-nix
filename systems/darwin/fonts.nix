{pkgs, ...}: {
  fonts.packages = with pkgs; [
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
}
