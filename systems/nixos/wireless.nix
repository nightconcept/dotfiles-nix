# WARNING: Keep this file encrypted
{
  pkgs,
  lib,
  config,
  ...
}: {
  options.wireless = {
    enable = lib.mkEnableOption "Enable wireless";
  };

  config = lib.mkIf config.wireless.enable {
    networking.networkmanager = {
      enable = true;
      # This allows wpa_applicant in networking.wireless to concurrently be run, but has a side
      # effect of disabling wired connections from working
      unmanaged = ["*" "except:type:wwan" "except:type:gsm"];
    };

    networking.wireless = {
      enable = true;
      networks = {
        "AIRMANS PARTY CENTRAL-5G" = {
          psk = "alphadelta";
        };
        "GarminGuests" = {
        };
      };
    };
  };
}
