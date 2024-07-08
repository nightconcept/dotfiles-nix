{pkgs, ...}: {
  hardware = {
    graphics = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        mesa
      ];
    };
  };
}
