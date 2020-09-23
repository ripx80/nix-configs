{ pkgs, ... }:

{
    home = {
        packages = with pkgs; [ conky ];
        file.".conkyrc".source = ./conkyrc;
    };
}