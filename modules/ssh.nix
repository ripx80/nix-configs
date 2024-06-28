{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.ssh;
  pkgDesc = "enable sshd server with default settings";
in
{
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
        # dont change KexAlgorithms, because this effect the initrd sshd_config
        /*
          "ecdh-sha2-nistp521"
          "ecdh-sha2-nistp384"
          "ecdh-sha2-nistp256"
        */
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];

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
      # mozilla recomended
      # ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
      hostKeyAlgorithms = [
        "ssh-ed25519"
        "ssh-rsa"
      ];
      pubkeyAcceptedKeyTypes = [ "ssh-ed25519" ];
      knownHosts = cfg.knownHosts;
    };
    services.openssh.openFirewall = false;
  };
}
