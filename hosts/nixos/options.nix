{lib, ...}: let
  mkOpt = lib.mkOption;
  types = lib.types;
in {
  # Declare what settings a user of this "options.nix" module CAN SET.
  options.host = {
    settings = {
      monitor = {
        count = mkOpt {
          type = types.int;
          default = 1;
          description = "count of monitors";
        };
        # Not expecting more than 2 monitors
        resolution-primary = mkOpt {
          type = types.str;
          default = "1920x1080";
          description = "resolution of primary monitor";
        };
        resolution-secondary = mkOpt {
          type = types.str;
          default = "1920x1080";
          description = "resolution of secondary monitor";
        };
      };
    };
  };
}
