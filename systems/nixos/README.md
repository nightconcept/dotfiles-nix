# Systems/NixOS

## network-drives
Relies on <SERVER_NAME>-secrets in /etc/nixos for now in the following format to gain network access:
```
username=<USERNAME>
domain=<DOMAIN>
password=<PASSWORD>
```
Source: https://nixos.wiki/wiki/Samba#CIFS_mount_configuration

## network.nix and wireless.nix
Each host must import one of these to get network access:
- network.nix
- wireless.nix

This is because the network manager will filter out managing any ethernet lines.
WARNING: This also means a wired port on a laptop will not work.