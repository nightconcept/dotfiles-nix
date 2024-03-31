{pkgs, ...}: {
  # System specific packages
  environment.systemPackages = with pkgs; [
    aldente
  ];
}
