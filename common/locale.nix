{ config, pkgs, ... }:

{
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    };
    time.timeZone = "Europe/Berlin";
}