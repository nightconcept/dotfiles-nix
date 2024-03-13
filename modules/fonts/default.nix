{ inputs, pkgs, lib, ... }:
{

  fonts = {
    fontconfig.enable = true;
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