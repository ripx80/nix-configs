{ config, pkgs, ... }:

let
    secret = import ../../secrets/hosts/vm/;
    inherit (secret) wg_server_ip wg_server_pub;
in {
  imports =
    [
      ./hardware-configuration.nix
      ../../common/users
      ../../common/base.nix
      ../../common/desktop.nix
      ../../common/locale.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "20.03";


  environment.systemPackages = with pkgs; [
    nano
    git
    wireguard
    iptables
    tcpdump
    xorg.xf86videovboxvideo
    #xorg.xf86videointel
    #xorg.xf86videoati
    #xorg.xf86videonouveau
  ];

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  networking.hostName = "nix";
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.firewall.enable = false;
  services.openssh.enable = true;

  #networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.nameservers = [ "192.168.100.1" ];

  # Wireguard client
  # fwmark not supported
  # set new default route not supported = AllowedIps 0.0.0.0/0
  # all solutions fight with fwmark and namespaces
  # bug with systemd config file. add a newline so he not found the wg cmd


  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "192.168.100.25/32" ];
      privateKeyFile = "/home/rip/nix-configs/secrets/hosts/vm/wgpriv";
      #listenPort = 51820;

      dns = [ "192.168.100.1" ];
      #table = "51820";

      peers = [
        {
          allowedIPs = [ "192.168.100.0/24" ];
          publicKey =   wg_server_pub;
          endpoint = wg_server_ip;
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.xserver = {
    videoDrivers = [ "virtualbox" ];
    resolutions = [
      { x = 1280; y = 720; }
      { x = 1920; y = 1080; }
      { x = 2560; y = 1440; }
    ];
  };
}

