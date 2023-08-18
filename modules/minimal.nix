{ config, pkgs, lib, pub, ... }: {

  ripmod = {
    hardware.enable = true;
    boot.enable = true;
    banner.enable = true;
    power.enable = true;
    ssh = {
      enable = true;
      knownHosts = pub.knownHosts;
    };
  };

  fileSystems."/mnt/stick" = {
    device = "/dev/sdc1";
    fsType = "auto";
    options = [ "defaults" "user" "rw" "noauto" "uid=1000" "gid=100" ];
  };

  environment.systemPackages = [ pkgs.nano ];
  networking.firewall.enable = true;
  services.timesyncd.enable = true;
}
