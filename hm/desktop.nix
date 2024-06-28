{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.gui;
in
{
  imports = [
    ./openbox
    ./alacritty
    ./conky
    ./zathura
    ./neofetch
    ./keybase
    ./wireshark
  ];

  options = {
    ripmod.gui.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable gui programs";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    ripmod = {
      openbox.enable = true;
      alacritty.enable = true;
      conky.enable = true;
      zathura.enable = true;
      neofetch.enable = true;
      keybase.enable = false; # enable if you needed
      keybase.gui = false;
      wireshark.enable = false; # home-manager not support programs.wireshark.enable = true;
    };
    home.packages = with pkgs; [
      google-chrome
      killall
      file
      spotify
      hack-font
      vscode
      pavucontrol
      rxvt_unicode
      pavucontrol
      geeqie
      xlockmore
    ];
  };
}
