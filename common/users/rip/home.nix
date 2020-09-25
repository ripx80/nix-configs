{ config, pkgs, ... }:

{
  imports =
  [
      ./home-desktop.nix
  ];

  home.sessionVariables = {
    EDITOR = "nano";
  };

#   environment.shellInit = ''
#     export GPG_TTY="$(tty)"
#     gpg-connect-agent /bye
#     export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
#   '';

  home.packages = with pkgs; [
    unzip
    rustup
    niv
    # rust alternatives
    bat
    exa
    fd
    procs
    sd
    du-dust
    ripgrep
    ytop
    bandwhich
    # grex download from github
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };

  programs.git = {
    enable = true;
    userName = "ripx80";
    userEmail = "ripx80@protonmail.com";
    aliases = {
        permission-reset = "!git diff -p -R --no-color | grep -E \"^(diff|(old|new) mode)\" --color=never | git apply";
    };
    extraConfig = {
        http = { sslCAinfo = "/etc/ssl/certs/ca-certificates.crt"; };
        push = { default = "matching"; };
    };
    # signing = {
    #   key = "me@yrashk.com";
    #   signByDefault = true;
    # };
  };
  programs.go.enable = true;

}