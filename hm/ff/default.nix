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
    ripmod.ff.enable = mkEnableOption "Firefox";
  };
  config = mkIf cfg.enable {

    # settings: https://librewolf.net/docs/settings/
    # arkenfox
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        # add policies here...

        # ---- EXTENSIONS ----
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };

          # add extensions here...
        };
        languagePacks = ["en-US" "de"];

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


      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        AppAutoUpdate = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
      };
      profiles = {
        default = {

          id = 0;
          name = "default";
          isDefault = true;
          # extraConfig =include user.js
          bookmarks =[
            {
                name = "wikipedia";
                tags = [ "wiki" ];
                keyword = "wiki";
                url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
            }
            {
                name = "kernel.org";
                url = "https://www.kernel.org";
            } ];

          settings = {
            "browser.startup.homepage" = "about:blank";
            "browser.search.defaultenginename" = "Searx";
            "browser.search.order.1" = "Searx";
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

            "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
            "cookiebanners.service.mode" = 2; # Block cookie banners

            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown.cookies" = true;

            "privacy.resistFingerprinting" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.donottrackheader.enabled" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;

            "webgl.disabled" = true;

            ## personal
            "browser.aboutwelcome.enabled" = false;
            "browser.translations.automaticallyPopup" = false;
            "identity.fxaccounts.enabled" = false;
          };
      };
    };
  };
};
}
