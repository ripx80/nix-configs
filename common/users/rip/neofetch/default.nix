{ pkgs, ... }:

{
    home = {
        packages = with pkgs; [ neofetch ];
        file.".config/neofetch/config.conf".source = ./config.conf;
    };

}