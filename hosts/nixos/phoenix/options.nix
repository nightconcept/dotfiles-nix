{options, ...}: {
  imports = [
    ../options.nix
  ];
  options.host.monitor.count = 1;
}
