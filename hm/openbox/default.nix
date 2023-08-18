{ pkgs, config, lib, ... }:

with lib;
let cfg = config.ripmod.openbox;
in {
  options = { ripmod.openbox.enable = mkEnableOption "Openbox"; };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ openbox hsetroot xcompmgr ];
      file.".config/openbox/autostart.sh".source = ./autostart.sh;
      file.".config/openbox/menu.xml".source = ./menu.xml;
      file.".config/openbox/rc.xml".source = ./rc.xml;
      file.".xinitrc".source = ./xinitrc;
    };
  };
}

