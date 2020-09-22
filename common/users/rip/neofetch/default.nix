{ pkgs, ... }:

{
    home = {
        home.packages = with pkgs; [ neofetch ];
        file.".config/neofetch/config.confh".source = ./config.conf;
    };

}