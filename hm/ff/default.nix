{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.ff;
in
{
  options = {
    ripmod.ff = {
      enable = mkEnableOption "Firefox";
      # not working in hm with meta input
      #   bookmarks = mkOption {
      #     type = types.listOf (types.attrsOf types.str);
      #     default = [ ];
      #     description = "add bookmarks";
      #   };
    };
  };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisplayBookmarksToolbar = "always";
          DisablePocket = true;
          # add policies here...

          # ---- EXTENSIONS ----
          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
          };
          languagePacks = [
            "en-US"
            "de"
          ];

          # ---- PREFERENCES ----
          # Set preferences shared by all profiles.
          Preferences = {
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            # add global preferences here...
          };
        };
      };

      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          path = "profiles/default";

          # extraConfig =include user.js
          bookmarks = [
            {
              #Toolbar Folder
              name = "toolbar";
              toolbar = true;
              bookmarks = [
                {
                  name = "";
                  url = "https://lobste.rs/";
                }
                {
                  name = "ms";
                  url = "https://marginalia-search.com/";
                }
                {
                  name = "";
                  url = " https://pomofocus.io/";
                }
              ];
            }
          ];
          search = {
            force = true;
            default = "DuckDuckGo";
            order = [ "DuckDuckGo" ];
            engines = {
              #   "Searx" = {
              #     urls = [{ template = "https://searx.aicampground.com/?q={searchTerms}"; }];
              #     iconUpdateURL = "https://nixos.wiki/favicon.png";
              #     updateInterval = 24 * 60 * 60 * 1000; # every day
              #     definedAliases = [ "@searx" ];
              #   };

              "DuckDuckGo" = {
                urls = [ { template = "https://duckduckgo.com/?q={searchTerms}"; } ];
              };
              "Bing".metaData.hidden = true;
              "Wikipedia".metaData.hidden = true;
              "Google".metaData.hidden = true;
            };
          };
          # https://github.com/arkenfox/user.js/blob/master/user.js
          settings = {
            /*
                manual steps:
                    - change default engine
                    - toogle bookmark toolbar
            */

            #?
            "browser.search.serpEventTelemetryCategorization.enabled" = false;
            # disable pasword check
            "security.password_lifetime.enabled" = false;
            # no formfill
            "browser.formfill.enabled" = false;
            # disable sync
            "services.sync.enabled" = false;
            # disable firefox accounts
            "identity.fxaccounts.enabled" = false;
            "browser.shell.checkDefaultBrowser" = false;

            /**
              UI (User Interface) **
            */
            # display warning on the padlock for "broken security"
            "security.ssl.treat_unsafe_negotiation_as_broken" = true;
            # display advanced information on Insecure Connection warning pages
            "browser.xul.error_pages.expert_bad_cert" = true;
            # no welcome on first start
            "browser.aboutwelcome.enabled" = false;
            # no popup for translation
            "browser.translations.automaticallyPopup" = false;
            # Start with a blank page
            "browser.startup.page" = 0;
            "browser.startup.homepage" = "about:blank";
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
            "browser.startup.blankWindow" = true;
            # New tab opens a blank page
            "browser.newtabpage.enabled" = false;
            "browser.newtab.url" = "about:blank";
            # disable about:config warning
            "browser.aboutConfig.showWarning" = false;
            # disable sponsored content on Firefox Home (Activity Stream)
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            # disable session restore
            "browser.sessionstore.resume_session_once" = false;
            "browser.sessionstore.max_tabs_undo" = 10; # changed
            # disable welcome notices
            "browser.startup.homepage_override.mstone" = "ignore";
            # disable General>Browsing>Recommend extensions/features as you browse
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            # disable search terms
            "browser.urlbar.showSearchTerms.enabled" = false;
            # enable toolbar
            "browser.toolbar.uiCustomization.enabled" = true;
            # disable suggest bookmarks
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.engines" = false;


            /**
              SEARCH **
            */
            # this not working
            "browser.search.defaultenginename" = "DuckDuckGo";
            "browser.search.order.1" = "DuckDuckGo";
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.search.selectedEngine" = "DuckDuckGo";
            "browser.search.searchEnginesURL" = "https://duckduckgo.com/?q=%s"; # not get default engines
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
            "browser.newtabpage.activity-stream.weather.locationSearchEnabled" = false;

            /**
              PREFETCH **
            */
            # Disable DNS prefetching
            "network.dns.disablePrefetch" = true;
            "network.dns.disablePrefetchFromHTTPS" = true;
            # disable predictor / prefetching
            "network.predictor.enabled" = false;
            "network.predictor.enable-prefetch" = false;
            # disable link-mouseover opening connection to linked server
            "network.http.speculative-parallel-limit" = 0;
            # disable mousedown speculative connections on bookmarks and history
            "browser.places.speculativeConnect.enabled" = false;
            # Disable prefetching of web pages
            "network.prefetch-next" = false;
            # Disable WebRTC to prevent IP leaks
            "media.peerconnection.enabled" = false; # maybe disable
            # Disable JavaScript asm.js (can be used for attacks)
            "javascript.options.asmjs" = false; # maybe disable
            # Prevent websites from detecting copy, paste, and cut events
            "dom.event.clipboardevents.enabled" = false; # maybe disable
            # Prevent access to battery status
            "dom.battery.enabled" = false;

            /**
              COOKIES **
            */
            # Block cookie banners in private browsing
            "cookiebanners.service.mode.privateBrowsing" = 2;
            # Block cookie banners
            "cookiebanners.service.mode" = 2;

            /**
              TELEMETRY **
            */
            # disable Firefox Home (Activity Stream) telemetry
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            # Disable Firefox data reporting
            "browser.ping-centre.telemetry" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            # Prevent websites from sending tracking pings
            "beacon.enabled" = false;
            # Prevent access to camera and microphone
            "media.navigator.enabled" = false;
            # Disable DRM (EME)
            "media.eme.enabled" = false;
            # Disable autoplay of media
            "media.autoplay.default" = 5;
            # disable recommendation pane in about:addons (uses Google Analytics)
            "extensions.getAddons.showPane" = false;
            # disable recommendations in about:addons' Extensions and Themes panes
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            # disable personalized Extension Recommendations in about:addons and AMO
            "browser.discovery.enabled" = false;
            # disable shopping experience
            "browser.shopping.experience2023.enabled" = false;
            # disable Health Reports
            "datareporting.healthreport.uploadEnabled" = false;
            # disable telemetry
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
            # disable Captive Portal detection
            "captivedetect.canonicalURL" = "";
            # disable Network Connectivity checks
            "network.connectivity-service.enabled" = false;

            /**
              STUDIES **
            */
            # Privacy & Security>Firefox Data Collection and Use>Install and run studies
            "app.shield.optoutstudies.enabled" = false;
            # disable Normandy/Shield
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";

            /**
              CRASH REPORTS **
            */
            # disable Crash Reports
            "reakpad.reportURL" = "";
            "browser.tabs.crashReporting.sendReport" = false;
            # enforce no submission of backlogged Crash Reports
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            "network.captive-portal-service.enabled" = false;

            /**
              * DNS / DoH / PROXY / SOCKS **
            */
            # for the future
            #"network.proxy.socks_remote_dns" = true;
            # disable using UNC (Uniform Naming Convention) paths
            #"network.file.disable_unc_paths" = true;
            # disable GIO as a potential proxy bypass vector
            #"network.gio.supported-protocols" = "";

            /**
              * LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS **
            */
            # disable location bar making speculative connections
            "browser.urlbar.speculativeConnect.enabled" = false;
            # disable location bar contextual suggestions
            "browser.urlbar.quicksuggest.enabled" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            # disable live search suggestions
            "browser.search.suggest.enabled" = false;
            # Disable suggestions in the address bar
            "browser.urlbar.suggest.searches" = false;
            # disable urlbar trending search suggestions
            "browser.urlbar.trending.featureGate" = false;
            # disable urlbar suggestions
            "browser.urlbar.addons.featureGate" = false;
            "browser.urlbar.fakespot.featureGate" = false;
            "browser.urlbar.mdn.featureGate" = false;
            "browser.urlbar.pocket.featureGate" = false;
            "browser.urlbar.weather.featureGate" = false;
            "browser.urlbar.yelp.featureGate" = false;
            # disable coloring of visited links
            # enabled this for user expr.
            "layout.css.visited_links_enabled" = true;

            # Disable form autofill
            "browser.formfill.enable" = false;
            # Disable credit card autofill
            "extensions.formautofill.creditCards.enabled" = false;
            #enable separate default search engine in Private Windows and its UI setting
            "browser.search.separatePrivateDefault" = false;
            "browser.search.separatePrivateDefault.ui.enabled" = true;

            /**
              * PASSWORDS **
            */
            # disable auto-filling username & password form fields
            "signon.rememberSignons" = false;
            # disable auto-filling username & password form fields
            "signon.autofillForms" = false;
            # disable formless login capture for Password Manager
            "signon.formlessCapture.enabled" = false;
            # limit (or disable) HTTP authentication credentials dialogs triggered by sub-resources
            "network.auth.subresource-http-auth-allow" = 1;

            /**
              * DISK AVOIDANCE **
            */
            # disable disk cache, enabled for performance
            "browser.cache.disk.enable" = true;
            # set media cache in Private Browsing to in-memory and increase its maximum size
            "browser.privatebrowsing.forceMediaMemoryCache" = true;
            "media.memory_cache_max_size" = 65536;
            # disable storing extra session data
            "browser.sessionstore.privacy_level" = 2;

            /**
               HTTPS (SSL/TLS / OCSP / CERTS / HPKP)
            */
            # require safe negotiation
            "security.ssl.require_safe_negotiation" = true;
            # disable TLS1.3 0-RTT
            "ecurity.tls.enable_0rtt_data" = false;

            /**
                  OCSP (Online Certificate Status Protocol)
            */
            # enforce OCSP fetching to confirm current validity of certificates
            "security.OCSP.enabled" = 1; # default
            # set OCSP fetch failures to hard-fail
            "security.OCSP.require" = true;

            /**
              CERTS / HPKP (HTTP Public Key Pinning)
            */
            # enable strict PKP (Public Key Pinning)
            "security.cert_pinning.enforcement_level" = 2;
            # enable CRLite
            "security.remote_settings.crlite_filters.enabled" = true;
            "security.pki.crlite_mode" = 2;

            /**
              CONTAINERS
            */
            # enable Container Tabs and its UI setting
            "privacy.userContext.enabled" = true;
            "privacy.userContext.ui.enabled" = true;

            /**
              * PLUGINS / MEDIA / WEBRTC **
            */
            # force WebRTC inside the proxy
            "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
            # force a single network interface for ICE candidates generation
            "media.peerconnection.ice.default_address_only" = true;

            /**
              EXTENSIONS **
            */
            # limit allowed extension directories
            "extensions.enabledScopes" = 5;
            # disable bypassing 3rd party extension install prompts
            "extensions.postDownloadThirdPartyPrompt" = false;

            /**
              * ETP (ENHANCED TRACKING PROTECTION) **
            */
            # ETP Strict Mode enables Total Cookie Protection (TCP)
            "browser.contentblocking.category" = "strict";
            # disable ETP web compat features
            "privacy.antitracking.enableWebcompat" = false;

            /**
              * SHUTDOWN & SANITIZING **
            */
            # enable Firefox to clear items on shutdown
            "privacy.sanitize.sanitizeOnShutdown" = true;
            # set/enforce clearOnShutdown items

            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
            "privacy.clearOnShutdown_v2.downloads" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.clearOnShutdown.openWindows" = true;
            # set "Cookies" and "Site Data" to clear on shutdown
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
            # set manual "Clear Data" items
            "privacy.clearSiteData.cache" = true;
            "privacy.clearSiteData.cookiesAndStorage" = false;
            "privacy.clearSiteData.historyFormDataAndDownloads" = true;

            # set manual "Clear Data" items
            "privacy.clearSiteData.browsingHistoryAndDownloads" = true;
            "privacy.clearSiteData.formdata" = true;
            "privacy.clearHistory.cache" = true;
            "privacy.clearHistory.cookiesAndStorage" = true;
            "privacy.clearHistory.historyFormDataAndDownloads" = true;
            "privacy.clearHistory.formdata" = true;
            # set "Time range to clear" for "Clear Data" (2820+) and "Clear History" (2830+)
            "privacy.sanitize.timeSpan" = 0;

            /**
              * FPP (fingerprintingProtection) **
            */
            # set RFP new window size max rounded values
            "privacy.window.maxInnerWidth" = 1600;
            "privacy.window.maxInnerHeight" = 900;
            # disable mozAddonManager Web API
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            # disable RFP spoof english prompt
            "privacy.spoof_english" = 1;
            # disable using system accent colors
            "widget.non-native-theme.use-theme-accent" = false;
            #  enforce links targeting new windows to open in a new tab instead
            "browser.link.open_newwindow" = 3;
            # set all open window methods to abide by "browser.link.open_newwindow"
            "browser.link.open_newwindow.restriction" = 0;
            # disable WebGL (Web Graphics Library)
            # "webgl.disabled" = false;

            /**
              MIXED CONTENT **
            */
            # disable insecure passive content (such as images) on https pages
            # "security.mixed_content.block_display_content" = true;
            # enable HTTPS-Only mode in all windows
            "dom.security.https_only_mode" = true;
            # disable HTTP background requests
            "dom.security.https_only_mode_send_http_background_request" = false;
            # control the amount of cross-origin information to send
            "network.http.referer.XOriginTrimmingPolicy" = 2;
            # Restrict referer headers across domains
            # "network.http.referer.XOriginPolicy" = 2; # can break things
            # prevent scripts from moving and resizing open windows
            "dom.disable_window_move_resize" = true;
            # remove temp files opened from non-PB windows with an external application
            "browser.download.start_downloads_in_tmp_dir" = true;
            "browser.helperApps.deleteTempFileOnExit" = true;
            # disable UITour backend so there is no chance that a remote page can use it
            "browser.uitour.enabled" = false;
            "browser.uitour.url" = "";
            # remove special permissions for certain mozilla domains
            "permissions.manager.defaultsUrl" = "";
            # use Punycode in Internationalized Domain Names to eliminate possible spoofing
            "network.IDN_show_punycode" = true;
            # enforce PDFJS, disable PDFJS scripting
            "pdfjs.disabled" = false; # default
            "pdfjs.enableScripting" = false;
            # disable middle click on new tab button opening URLs or searches using clipboard
            "browser.tabs.searchclipboardfor.middleclick" = false;
            # disable downloads panel opening on every download
            "browser.download.alwaysOpenPanel" = false;
            # disable adding downloads to the system's "recent documents" list
            "browser.download.manager.addToRecentDocs" = false;
            # enable user interaction for security by always asking how to handle new mimetypes
            "browser.download.always_ask_before_handling_new_types" = true;
            # disable geolocation on linux
            "geo.provider.use_geoclue" = false;
          };
        };
      };
    };
  };
}
