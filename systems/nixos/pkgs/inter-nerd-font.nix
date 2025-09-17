{ lib, stdenvNoCC, fetchzip, fontforge, python3 }:

stdenvNoCC.mkDerivation rec {
  pname = "inter-nerd-font";
  version = "4.0";
  
  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
    stripRoot = false;
    hash = "sha256-hFK7xFJt69n+98+juWgMvt+zeB9nDkc8nsR8vohrFIc=";
  };
  
  nerdfonts = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FontPatcher.zip";
    sha256 = "sha256-3s0vcRiNA/pQrViYMwU2nnkLUNUcqXja/jTWO49x3BU=";
    stripRoot = false;
  };
  
  buildInputs = [ fontforge python3 ];
  
  buildPhase = ''
    # Copy the font patcher
    cp -r $nerdfonts/* .
    
    # Patch Inter fonts
    for font in Inter*.ttf; do
      echo "Patching $font..."
      python font-patcher "$font" --complete --out . || true
    done
  '';
  
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    # Install original Inter fonts
    cp Inter*.ttf $out/share/fonts/truetype/
    # Install patched versions if they exist
    cp *Nerd*.ttf $out/share/fonts/truetype/ 2>/dev/null || true
  '';
  
  meta = with lib; {
    description = "Inter font patched with Nerd Font symbols";
    homepage = "https://github.com/rsms/inter";
    license = licenses.ofl;
  };
}