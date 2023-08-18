{ config, pkgs, lib, specialArgs, ... }:
with lib;
let
  #inherit (specialArgs) x11;
in {
  imports = [
    ../../hm # default hm config
  ];
  home.sessionVariables = { EDITOR = "nano"; };
  home.packages = with pkgs; [ unzip ];
}
