{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}:
with lib;
let
in
#inherit (specialArgs) x11;
{
  imports = [
    ../../hm # default hm config
  ];
  home.sessionVariables = {
    EDITOR = "nano";
  };
  home.packages = with pkgs; [ unzip ];
}
