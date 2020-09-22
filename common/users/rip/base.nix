{ config, pkgs, ... }:

{
  imports =
  [
      ./neofetch.nix
  ];
  home.sessionVariables = {
    EDITOR = "nano";
  };

  home.packages = [
    pkgs.unzip
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };

  programs.git = {
    enable = true;
    userName = "ripx80";
    userEmail = "ripx80@protonmail.com";
    push.default = "matching";
    aliases = {
        permission-reset = "!git diff -p -R --no-color | grep -E \"^(diff|(old|new) mode)\" --color=never | git apply";
    };
    extraConfig = { http { sslCAinfo = "/etc/ssl/certs/ca-certificates.crt"; }; };
    # signing = {
    #   key = "me@yrashk.com";
    #   signByDefault = true;
    # };
  };

}