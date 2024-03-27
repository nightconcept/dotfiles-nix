{
  lib,
  config,
  ...
}: {
  # Declare what settings a user of this "options.nix" module CAN SET.
  options.host = {
    settings = {
      monitor = {
        count = mkOption {
          type = types.int;
          default = 1;
          description = "count of monitors"
        };
        # Not expecting more than 2 monitors
        resolution-primary = mkOption {
          type = types.str;
          default = "1920x1080";
          description = "resolution of primary monitor";
        };
        resolution-secondary = mkOption {
          type = types.str;
          default = "1920x1080";
          description = "resolution of secondary monitor";
        };        
    };
  };
}
