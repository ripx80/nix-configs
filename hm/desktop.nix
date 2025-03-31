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
    ./librewolf
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
      alacritty.enable = true; # use ghostty
      conky.enable = true;
      zathura.enable = true;
      # neofetch.enable = true;
      # keybase.enable = false; # enable if you needed
      # keybase.gui = false;
      wireshark.enable = false; # home-manager not support programs.wireshark.enable = true;
      librewolf.enable = true;
    };
    home.packages = with pkgs; [
      google-chrome # use librewolf instead
      #librewolf # try to configrue https://nixos.wiki/wiki/Librewolf
      killall
      file
      spotify # search for a alternative
      hack-font
      vscode # search for a alternative
      pavucontrol
      rxvt_unicode # use ghostty
      pavucontrol
      geeqie
      xlockmore
    ];
  };
}
