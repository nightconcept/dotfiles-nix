{ inputs, pkgs, lib, ... }:
{
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override
        { fonts = [ 
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
}