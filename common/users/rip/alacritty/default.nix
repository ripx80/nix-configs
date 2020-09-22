{ pkgs, ... }:

{
    home = {
        packages = with pkgs; [ alacritty ];
        file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
    };
}

