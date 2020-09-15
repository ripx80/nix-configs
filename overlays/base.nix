{ config, lib, pkgs, ... }:

with lib; {
    config = {
        boot.cleanTmpDir = true;

        nix = {
        autoOptimiseStore = true;
        trustedUsers = [ "root" "rip" ];
        };
        nixpkgs.config = {
        allowUnfree = true;
        };
    };
    environment.systemPackages = with pkgs; [
    nano
    git
    wireguard
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
        keyMap = "de";
    };
    time.timeZone = "Europe/Berlin";
}