{ config, pkgs, lib, unstable, ... }:
/* module:
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

in {
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
      hostKey = mkOption {
        type = types.path;
        description = boot.initrd.network.ssh.hostKeys.description;
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
  config = mkIf cfg.enable {

    boot = {
      loader.grub.enableCryptodisk = true;
      kernelParams = [ cfg.kernelParams ];
      initrd = {
        luks.forceLuksSupportInInitrd = true;
        availableKernelModules = cfg.modules;
        network = {
          enable = true;
          flushBeforeStage2 = true; # resets network config from kernel

          /* postCommands:
             will be executed before other stuff happens
             use cases:
               - /bin/bash             : rescue shell inside initrd
               - chmod 0600 <ssh_key>  : set correct access rights on keys
               - cryptsetup-askpass    : ask for a password when ssh user login
               - ntpdate               : set time
                echo "ntp: starting ntpdate"
                echo "ntp   123/tcp" >> /etc/services
                echo "ntp   123/udp" >> /etc/services
                ntpdate 0.pool.ntp.org
          */
          postCommands = ''
            echo 'cryptsetup-askpass' >> /root/.profile
          '';
          ssh = {
            enable = true;
            port = 2222;
            authorizedKeys = cfg.pubKeys;
            hostKeys = [ cfg.hostKey ];
            # shell must be present on the system: public key error
            #shell = "/bin/bash"; # default /bin/ash
          };
        };
        /* copy binarys to initrd, ipconfig is available
           use cases:
             extraUtilsCommands = ''
               copy_bin_and_libs ${pkgs.bash}/bin/bash
               copy_bin_and_libs ${pkgs.ntp}/bin/ntpdate
             '';
           copy_bin_and_libs ${pkgs.wireguard}/bin/wg
        */
      };
    };
  };
}
