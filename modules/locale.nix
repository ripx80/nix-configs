{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.locale;
  pkgDesc = "default locales";
in
{
  options = {
    ripmod.locale = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      earlySetup = true;
      font = "Lat2-Terminus16";
      keyMap = "de-latin1-nodeadkeys";
    };
    time.timeZone = "Europe/Berlin";
    time.hardwareClockInLocalTime = true;
  };
}
