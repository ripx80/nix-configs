{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ripmod.ssh;
  pkgDesc = "enable sshd server with default settings";
in {
  options = {
    ripmod.ssh = {
      enable = mkEnableOption pkgDesc;
      knownHosts = mkOption { description = "set knownHosts"; };
    };
  };
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        #KexAlgorithms = [];
        #Ciphers = [];

      };
      allowSFTP = true;
      extraConfig = ''
        AllowTcpForwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
        PubkeyAcceptedKeyTypes ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
      '';
    };
    programs.ssh = {
      hostKeyAlgorithms = [ "ssh-ed25519" "ssh-rsa" ];
      pubkeyAcceptedKeyTypes = [ "ssh-ed25519" ];
      knownHosts = cfg.knownHosts;
    };
    networking.firewall = { allowedTCPPorts = [ 22 ]; };
  };
}
