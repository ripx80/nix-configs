{ config, pkgs, lib, ... }:

with lib;
let
    cfg = config.rip.gui;
in {
    # imports =
    #     [
    #         ./openbox
    #         ./alacritty
    #         ./conky
    #         ./zathura
    #     ];

    options = {
        rip.gui.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''enable gui programs for rip'';
        };
    };

    config = mkIf cfg.enable {
        nixpkgs.config.allowUnfree = true;
        home.packages = with pkgs; [
            google-chrome
            killall
            file
            spotify
            spotify
            hack-font
            vscode
            pavucontrol
            hack-font
            # rxvt_unicode
            vscode
            pavucontrol
        ];
    };
}