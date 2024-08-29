{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.openbox;
in
{
  options = {
    ripmod.openbox.enable = mkEnableOption "Openbox";
    ripmod.openbox.notebook = mkOption {
      type = types.bool;
      default = false;
      description = "enable hdpi options, brightness control for openbox and X";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.notebook) {
      home = {
        packages = with pkgs; [
          brightnessctl
          xorg.xmodmap
        ];
        file.".config/openbox/autostart.sh".source = ./autostart_notebook.sh;
        file.".Xresources".source = ./Xresources;
        file.".xinitrc".source = ./xinitrc_notebook;
        file.".Xmodmap".source = ./Xmodmap_notebook;
      };
    })
    (mkIf (!cfg.notebook) {
      home = {
        file.".config/openbox/autostart.sh".source = ./autostart.sh;
        file.".xinitrc".source = ./xinitrc;
      };
    })
    ({
      home = {
        packages = with pkgs; [
          openbox
          hsetroot
          xcompmgr
        ];
        file.".config/openbox/menu.xml".source = ./menu.xml;
        file.".config/openbox/rc.xml".source = ./rc.xml;
      };
    })
  ]);
}
