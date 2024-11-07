{
  config,
  pkgs,
  lib,
  pub,
  ...
}:
{

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
    options = [
      "defaults"
      "user"
      "rw"
      "noauto"
      "uid=1000"
      "gid=100"
    ];
  };

  environment.systemPackages = [ pkgs.nano ];
  networking.firewall.enable = true;
  networking.enableIPv6 = false;
  # remember, when using wireguard it will load ip6 and ipv6_upd_tunnel
  # you get ipv6 udp on lo, its a dependency
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = true;
  };
  services.timesyncd.enable = lib.mkDefault true;
  # boot.kernelPackages = pkgs.linuxPackages_latest; # todo
}
