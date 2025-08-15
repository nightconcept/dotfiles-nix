final: prev: {
  plex = prev.plex.overrideAttrs (old: rec {
    version = "1.42.1.10060-4e8b05daf";
    src = final.fetchurl {
      url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
      sha256 = "sha256-OoItvG0IpgUKlZ0JmzDc2WqMtyZrlNCF7MCnUKqBl/Q=";
    };
  });
}