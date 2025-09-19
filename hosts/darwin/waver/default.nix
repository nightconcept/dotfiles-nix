# Waver - MacBook Pro M1 (laptop)
{ pkgs, ... }: {
  # Enable Darwin modules for laptop
  modules.darwin = {
    core.enable = true;
    homebrew = {
      enable = true;
      systemType = "laptop";
    };
    systemSettings = {
      enable = true;
      systemType = "laptop";
    };
  };

  # System specific packages
  environment.systemPackages = with pkgs; [
    aldente
  ];
}
