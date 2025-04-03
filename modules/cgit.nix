/*
todo:
- dns and cert
- create module
- with and without nginx on system
- add logo
- no to editor

- integrate on ripgate
    - cgit with config
    - opkg install cgit git-http uhttpd

    # how to:
    # local init
    sudo -u git bash -c "git init --bare ~/myproject.git"
    # remote
    mkdir myproject
    cd myproject
    echo hello > a
    git init
    git add .
    git commit -m init
    git remote add origin git@myserver:myproject.git
    git push origin master
    # clone
    git clone git@myserver:myproject.git

*/
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ripmod.cgit;
  pkgDesc = "enable git server and cgit with nginx";
in
{
  options = {
    ripmod.cgit = {
      enable = mkEnableOption pkgDesc;
      pubKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "pubkeys to push via git user";
      };

    };
  };
  config = mkIf cfg.enable {
    users.users.git = {
    isSystemUser = true;
    description = "git general";
    home = "/var/lib/git";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = cfg.pubKeys;
    group = "git";
  };
  users.groups.git = {};
  services.openssh.extraConfig = ''
    Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no
  '';
  services.cgit."git" = {
    enable = true;
    scanPath = "/var/lib/git";
    user = "git";
    group = "git";
    settings = {
        # https://man.uex.se/5/cgitrc
        root-title="git internal";
        root-desc="git repos";
        # interpret readme
        readme=":README.md";
        # markdown and highlight
        about-filter="${pkgs.cgit}/lib/cgit/filters/about-formatting.sh";
        source-filter="${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py";
        #logo=/cgit.png
        #css = "/cgit.css"
        #favicon = "/favicon.ico"
        # enable-log-filecount = 1;
        # enable-log-linecount = 1;
    };
    nginx.virtualHost = "git";
  };
  };
}
