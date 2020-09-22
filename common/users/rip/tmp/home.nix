{ pkgs, ... }:

{
    programs.git = {
    enable = true;
    userName = "ripx80";
    userEmail = "ripx80@protonmail.com";
    push.default = "matching";
    http.sslCAinfo = "/etc/ssl/certs/ca-certificates.crt";
    aliases = {
        permission-reset = "!git diff -p -R --no-color | grep -E \"^(diff|(old|new) mode)\" --color=never | git apply";
    };
    # signing = {
    #   key = "me@yrashk.com";
    #   signByDefault = true;
    # };
  };
}