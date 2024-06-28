{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.ripmod.wireshark;
in
{
  options = {
    ripmod.wireshark.enable = mkEnableOption "wireshark";
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ wireshark ];
    };
  };
  # home-manager not support wireshark, do this with programs.wireshark.enable = true in normal nix config
  #   users.users.rip.extraGroups = [ "wireshark" ];
  #   users.groups.wireshark.gid = 503;
  #   security.wrappers.dumpcap = {
  #     source = "${pkgs.wireshark}/bin/dumpcap";
  #     permissions = "u+rx,g+x";
  #     owner = "root";
  #     group = "wireshark";
  #     setuid = true;
  #     setgid = false;
  #   };
}
