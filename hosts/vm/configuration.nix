{ config, pkgs, ... }:

{
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

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Wireguard client
  networking.wireguard.interfaces = {
    wg0 = {
      listenPort = 51820;
      ips = [ "192.168.100.25/32" ];
      #dns = [ "192.168.100.1" ];
      privateKeyFile = "/home/rip/vm/private";
      peers = [
        { publicKey = "SzfrmGsjYO5kSRvhNq251cMXq1mM3YBQOHXvVeZYxSc=";
          allowedIPs = [ "0.0.0.0/0, ::/0" ];
          endpoint = (builtins.readFile /home/rip/vm/server);
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

