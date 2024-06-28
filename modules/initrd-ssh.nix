{
  config,
  pkgs,
  lib,
  unstable,
  ...
}:
/*
  module:
       https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/initrd-ssh.nix

   Note that the SSH host keys will need to be stored in plain text,
   so an attacker with physical access can extract them and perform a MITM attack
   to intercept the keys when you try to reboot the system. Hence compared to an
   unencrypted disk this approach warrants only limited additional trust;
   if security matters, go on premise to reboot and verify the integrity of your hardware,
   use a TPM to tie the storage encryption keys to your system, or enforce physical security.

   hostKeys:
       - hostKey must be present on the target maschine (minimal-luks: /etc/ssh/<key>), will be copied on runtime
       - hostKey use initrd.secrets under the hood
       - hostKey can be set with "path/to/key" (eval on build) or /path/to/key (eval before), but you prefer the path
       - initrd.secrets must be supported by bootloader (systemd, grub2, ...)

   use this config if you disable hostKeys and add keys manually:
       ignoreEmptyHostKeys = true;
       extraConfig = ''
           HostKey /etc/ssh/ssh_host_ed25519_key_initrd
       '';

   initrd crypt keys on a usb device:
       Needed to find the USB device during initrd stage
       only needed if the kernel or header on a usb device
       boot.initrd.kernelModules = [ "usb_storage" ];

   extract initrd:
       zstd -d initrd-<version> -o initrd
       mkdir -p /tmp/cpio && cd /tmp/cpio && cpio -i < /boot/<initrd>
       or:
       zstd -d /nix/store/9wv6jn2y7qyy09wrm9qnghsa7vmbpraj-initrd-linux-6.1.38/initrd -c | cpio -i

   run initrd with qemu-system

       qemu-system-x86_64 -kernel result/kernel -initrd result/initrd

   some additional options to customize the initrd:

   extra config option to add files to initrd
       boot.initrd.extraUtilsCommands = ''
           echo '<some key>' >> $out/ssh_host_ed25519_key_test
       '';

   prepend to the final initrd we are building:
       boot.initrd.prepend = [ "file1" "file2"];

   Extra files to link and copy in to the initrd:
       boot.initrd.extraFiles = {
           <name>.source = "";
       };

    Shell commands to be executed immediately after stage 1:
       postDeviceCommands

    Shell commands to be executed immediately before LVM discovery:
       preLVMCommands = "";

   the secrets will be available in /.initrd-secrets.
   note that hostKeys use secrets inside, so you dont need so specify it here:
   secrets = {
       "/etc/ssh/ssh_host_ed25519_key_initrd" = "/etc/ssh/ssh_host_ed25519_key_initrd"; # string
       "/etc/ssh/ssh_host_ed25519_key_initrd" = /etc/ssh/ssh_host_ed25519_key_initrd; # path
   };

   issues:
       - https://discourse.nixos.org/t/early-boot-remote-decryption/16146/9
            problems to find the ssh key
       - https://github.com/NixOS/nixpkgs/issues/65375
            full disk encryption with encrypted /boot is not supported with grub2 and luks2
            /boot/efi -> grub not support luks2, wait for it
           boot.loader.efi.efiSysMountPoint = "/boot/efi";
       - https://github.com/NixOS/nixpkgs/issues/98741
            It may be necessary to wait a bit for devices to be initialized.
           boot.initrd.preLVMCommands = lib.mkBefore 400 "sleep 1";
       - https://github.com/NixOS/nixpkgs/issues/98100
           hostKeys using initrd secrets under the hood
           must be present when building, interal use of initrd.secrets, not be optimal
       - https://nixos.wiki/wiki/ZFS#:~:text=defaults%20to%20all).-,Remote%20unlock,-Unlock%20encrypted%20zfs
           hostKey must be a path not a string, you will be run into issues:
       - https://github.com/NixOS/nixpkgs/blob/dbf6c323883ae7e00941f628e65bdd58b3660e9a/nixos/modules/system/boot/initrd-ssh.nix#L115
           hostKey they will remove the first char from file name

       - there is a bug: if you set ssh.HostKey it will be overwritten if you set another secrets in initrd
       - because of the implementation and the problematic rebuild i use a unrusted meta key here
         its not a real secrets because it will expose in nix store and is readable if someone clone the repo and have the git-crypt keys.

   docs:
       - https://search.nixos.org/options?channel=22.11&show=boot.initrd.secrets&from=0&size=50&sort=relevance&type=packages&query=boot.initrd+
       - https://nixos.wiki/wiki/Full_Disk_Encryption
       - https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f
       - https://mth.st/blog/nixos-initrd-ssh/
       - https://pagefault.blog/2016/12/23/guide-encryption-with-tpm/
       - https://nixos.wiki/wiki/Remote_LUKS_Unlocking
*/
with lib;
let
  cfg = config.ripmod.initrd-ssh;
  pkgDesc = "ripmod initrd ssh service";
in
{
  options = {
    ripmod.initrd-ssh = {
      enable = mkEnableOption "enable initrd ssh service";

      modules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = boot.initrd.availableKernelModules.description;
      };
      pubKeys = mkOption {
        type = types.listOf types.str;
        description = boot.initrd.authorizedKeys.description;
      };
      # dont use regular keys they are exposed in the nix store
      # change to: types.package in the future
      hostKey = mkOption {
        type = types.str;
        description = "ssh host key in initrd. this will be saved on a unencrypted boot disk and exposed in nix store";
        #description = boot.initrd.network.ssh.hostKeys.description;
      };
      # dont use regular keys they are exposed in the nix store
      # change to: types.package
      wgConf = mkOption {
        type = types.str;
        description = "wireguard config file path";
        default = "";
      };

      wgIp = mkOption {
        type = types.str;
        description = "wireguard client ip";
        default = "";
      };

      kernelParams = mkOption {
        description = "kernel params string";
        example = ''
          doc: <https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt>
          ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>:<ntp0-ip>
          ip=192.168.1.80::192.168.1.1:255.255.255.0:minimal-initrd:enp1s0:off:9.9.9.9:8.8.8.8:
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      boot = {
        loader.grub.enableCryptodisk = true;
        kernelParams = [ cfg.kernelParams ];
        initrd = {
          luks.forceLuksSupportInInitrd = true;
          kernelModules = cfg.modules;
          network = {
            enable = true;
            flushBeforeStage2 = true; # flush interfaces
            postCommands = ''
              mkdir -p /etc/ssh/
              # !attention: keys not safe here
              echo "${cfg.hostKey}" >/etc/ssh/ssh_host_ed25519_key
              chmod 0600 /etc/ssh/ssh_host_ed25519_key
              #echo 'cryptsetup-askpass' >> /root/.profile
            '';
            ssh = {
              enable = true;
              port = 2222;
              authorizedKeys = cfg.pubKeys;
              ignoreEmptyHostKeys = true;
              # need to set a fixed KeyExchange method because the mtu will be not enough with ssh jump hosts inside a wg connection.
              # to avoid to set a lower mtu which can cause some problems we set a fixed method here.
              # this must be set in the sshd config file of the system:
              # KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
              extraConfig = ''
                PubkeyAcceptedKeyTypes ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
              '';
              shell = "/bin/cryptsetup-askpass";
              # shell must be present on the system: public key error
              #shell = "/bin/ash";
            };
          };
        };
      };
    })
    (mkIf (config.boot.initrd.network.enable && cfg.enable && (cfg.wgConf != "")) {
      boot.initrd = {
        kernelModules = [ "wireguard" ];
        # copy binarys to initrd, ipconfig is available
        # wireguard wg is a wrapper script, need the executable .wg-wrapped
        extraUtilsCommands = ''
          #copy_bin_and_libs ${pkgs.bash}/bin/bash
          copy_bin_and_libs ${pkgs.iproute2}/bin/ip
          copy_bin_and_libs ${pkgs.ntp}/bin/ntpdate
          copy_bin_and_libs ${pkgs.wireguard-tools}/bin/.wg-wrapped
          ln -sf $out/bin/.wg-wrapped $out/bin/wg
        '';
        network = {
          postCommands = ''
            # !attention: keys not safe here
            echo "${cfg.wgConf}" >/etc/wg.conf

            # use wg10 here because the interface persists after the system boots
            # dont use wg10 in your normal config

            ip link add dev wg10 type wireguard
            ip address add dev wg10 ${cfg.wgIp}
            # mtu can made a lot of problems. check that all your wg interfaces has the same mtu size
            # this can should end in connection problems like ssh.
            # some isp has a smaller mtu like 1460. the mtu must be adjusted.
            ip link set mtu 1380 dev wg10

            wg setconf wg10 /etc/wg.conf
            ip link set up dev wg10
          '';
        };
      };
    })
  ];
}
