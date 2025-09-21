{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt;

  # Check if we have inputs available (for flake-based configs)
  hasInputs = builtins.hasAttr "inputs" (builtins.functionArgs (import <nixpkgs> {})) || inputs != null;
in
{
  options.modules.home.programs.firefox = {
    enable = mkBoolOpt false "Enable Firefox with custom configuration";
  };

  config = lib.mkIf config.modules.home.programs.firefox.enable {
    programs.firefox = {
      enable = true;

      # Profile configuration
      profiles.danny = {
        isDefault = true;
        name = "danny";
        id = 0;

        # Search engines configuration
        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          order = [ "ddg" "google" ];
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
              icon = "https://wiki.nixos.org/favicon.png";
              definedAliases = [ "@nw" ];
            };
            "GitHub" = {
              urls = [{ template = "https://github.com/search?q={searchTerms}&type=code"; }];
              icon = "https://github.com/favicon.ico";
              definedAliases = [ "@gh" ];
            };
            "YouTube" = {
              urls = [{ template = "https://www.youtube.com/results?search_query={searchTerms}"; }];
              icon = "https://www.youtube.com/favicon.ico";
              definedAliases = [ "@yt" ];
            };
            "google".metaData.alias = "@g";
            "wikipedia".metaData.alias = "@wiki";
            "bing".metaData.hidden = true;
          };
        };

        # Bookmarks configuration
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Development";
              toolbar = true;
              bookmarks = [
                {
                  name = "GitHub";
                  url = "https://github.com";
                }
                {
                  name = "NixOS Search";
                  url = "https://search.nixos.org";
                }
                {
                  name = "Home Manager Options";
                  url = "https://nix-community.github.io/home-manager/options.html";
                }
              ];
            }
          ];
        };

        # Settings for better integration and privacy
        settings = {
          # Enable userChrome.css and userContent.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Force GTK theme and dark mode
          "widget.gtk.overlay-scrollbars.enabled" = true;
          "widget.content.gtk-theme-override" = "prefer-dark";

          # Dark theme preferences
          "ui.systemUsesDarkTheme" = 1;
          "browser.theme.content-theme" = 0; # 0 = dark
          "browser.theme.toolbar-theme" = 0; # 0 = dark
          "layout.css.prefers-color-scheme.content-override" = 0; # 0 = dark
          "browser.in-content.dark-mode" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

          # Enable WebRender and hardware acceleration
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "media.av1.enabled" = true;
          "media.ffvpx.enabled" = true;
          "layers.acceleration.force-enabled" = true;

          # Performance tweaks
          "dom.ipc.processCount" = 8;
          "browser.preferences.defaultPerformanceSettings.enabled" = false;
          "browser.startup.preXulSkeletonUI" = false; # Disable skeleton UI

          # UI customization
          "browser.toolbars.bookmarks.visibility" = "always"; # Show bookmarks toolbar
          "browser.compactmode.show" = true;
          "browser.uidensity" = 1; # Compact mode
          "browser.tabs.inTitlebar" = 1;
          "browser.newtabpage.enabled" = true;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

          # Homepage
          "browser.startup.homepage" = "https://heimdall.local.solivan.dev/";
          "browser.startup.page" = 3; # Restore previous session

          # Better scrolling
          "apz.overscroll.enabled" = true; # Elastic overscroll
          "general.smoothScroll" = true;
          "general.smoothScroll.mouseWheel.duration" = 200;
          "mousewheel.min_line_scroll_amount" = 25;

          # Privacy settings
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.firstparty.isolate" = false; # Can break some sites
          "privacy.resistFingerprinting" = false; # Can break sites
          "network.cookie.cookieBehavior" = 0; # Accept all cookies (matches your setting)
          "browser.contentblocking.category" = "custom"; # Custom tracking protection

          # Container support
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          # Security
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          # Disable telemetry and data collection
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;

          # Disable Pocket
          "extensions.pocket.enabled" = false;
          "extensions.pocket.api" = "";
          "extensions.pocket.site" = "";

          # Disable Mozilla account features
          "identity.fxaccounts.enabled" = false;
          "browser.tabs.firefox-view" = false;

          # Disable annoying features
          "browser.aboutConfig.showWarning" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.disableResetPrompt" = true;
          "browser.onboarding.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

          # Better downloads behavior
          "browser.download.panel.shown" = true;
          "browser.download.useDownloadDir" = false; # Always ask where to save
          "browser.download.alwaysOpenPanel" = false;
          "browser.download.manager.addToRecentDocs" = false;
          "browser.download.autohideButton" = false;
          "browser.download.lastDir" = "/home/danny/Downloads";

          # Developer tools
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;

          # Media
          "media.eme.enabled" = true; # Enable DRM for streaming services
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false; # Disabled per your settings

          # Other preferences from your profile
          "general.autoScroll" = true; # Enable autoscroll
          "accessibility.typeaheadfind.flashBar" = 0;
          "app.shield.optoutstudies.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "network.http.speculative-parallel-limit" = 0;

          # PDF viewer
          "pdfjs.enableScripting" = false; # Security
        };

        # Extensions - will be installed manually or via sync
        # Your extensions include: uBlock Origin, Bitwarden, Dark Reader, SponsorBlock,
        # 2FAS, Tampermonkey, Kagi Search, Obsidian Clipper, Multi-Account Containers, etc.
        # These will sync via Firefox Sync or can be installed manually
        extensions.packages = [];

        # Custom CSS for UI tweaks (userChrome.css)
        userChrome = ''
          /* Compact mode adjustments */
          :root {
            --tab-min-height: 29px !important;
            --urlbar-min-height: 29px !important;
          }

          /* Hide tab close button until hover */
          .tabbrowser-tab:not(:hover) .tab-close-button {
            display: none !important;
          }

          /* Smaller UI font */
          * {
            font-size: 12px !important;
          }

          /* Auto-hide bookmarks toolbar - show on hover */
          #PersonalToolbar {
            --uc-bm-height: 20px;
            --uc-bm-padding: 2px;
            position: relative;
            height: var(--uc-bm-height);
            overflow: hidden;
            transition: height 200ms ease-in-out;
          }

          #PersonalToolbar:hover {
            height: calc(var(--uc-bm-height) + var(--uc-bm-padding) * 2);
          }
        '';

        # Custom content CSS (userContent.css)
        userContent = ''
          /* Dark mode for about pages */
          @-moz-document url-prefix(about:) {
            :root {
              --in-content-page-background: #1a1b26 !important;
              --in-content-page-color: #a9b1d6 !important;
            }
          }
        '';
      };

      # Policies for enterprise configuration
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = false; # Keep enabled for sync if desired
        DisableSetDesktopBackground = true;
        DisplayBookmarksToolbar = "always"; # Show bookmarks toolbar
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
        };
        NoDefaultBookmarks = lib.mkForce true;
        OfferToSaveLogins = false; # We use Bitwarden
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        PasswordManagerEnabled = false; # Use Bitwarden instead
        SearchBar = "unified";
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
          WhatsNew = false;
        };
      };
    };

    # Set Firefox as default browser (Linux only)
    xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      defaultApplications = {
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/ftp" = ["firefox.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
        "application/x-extension-htm" = ["firefox.desktop"];
        "application/x-extension-html" = ["firefox.desktop"];
        "application/x-extension-shtml" = ["firefox.desktop"];
        "application/xhtml+xml" = ["firefox.desktop"];
        "application/x-extension-xhtml" = ["firefox.desktop"];
        "application/x-extension-xht" = ["firefox.desktop"];
      };
    };

    # Wayland environment variables are set in the Hyprland desktop module
  };
}