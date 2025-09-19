# Core NixOS modules - essential system configuration
{
  imports = [
    ./bootloader
    ./nix
    ./locale
    ./users
    ./packages
  ];
}