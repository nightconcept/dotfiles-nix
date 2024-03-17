{ inputs, pkgs, lib, ... }:
{

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
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