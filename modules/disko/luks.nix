{ disks ? [ "/dev/sda" ], ... }: {
  /* docs:
        - https://nixos.wiki/wiki/Full_Disk_Encryption
        - https://shen.hong.io/installing-nixos-with-encrypted-root-partition-and-seperate-boot-partition/
  */

  disko.devices = {
    disk.disk0 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "0";
            end = "512MiB"; # 512Mib #128MiB
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot"; # /boot/efi luks2 grub problem
              mountOptions = [ "defaults" "noatime" ];
            };
          }
          {

            name = "luks";
            start = "512MiB";
            end = "-2GiB";

            content = {
              type = "luks";
              name = "crypt";
              settings = {
                keyFile =
                  "/root/secret.key"; # dd if=/dev/urandom of=./keyfile0.bin bs=1024 count=4, this will be used by autoinstall and then in the config of the installed system
                fallbackToPassword = true; # allow to type in the password
              };

              initrdUnlock = true;

              # default command
              # cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --iter-time 2000 --key-size 256 --pbkdf argon2id --use-urandom --verify-passphrase luksFormat device
              extraFormatArgs = [ "--key-size 512" "--hash sha512" ];
              extraOpenArgs = [
                "--allow-discards"
              ]; # this has security implifications on luks
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                mountOptions = [
                  "defaults"
                  "discard=async"
                  "ssd"
                  "space_cache=v2"
                  "lazytime"
                ];
                subvolumes = {
                  "/__active" = {
                    # not be mounted
                    # mountOptions =
                    #   [ "noauto" "compress=zstd" "noatime" "autodefrag" ];

                  };
                  "/__snapshot" = {
                    # not be mounted
                    # mountOptions =
                    #   [ "noauto" "compress=zstd" "noatime" "autodefrag" ];
                  };
                  "/__active/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
                  };
                  "/__active/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
                  };
                  "/__active/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
                  };
                };
              };
            };
          }
          {
            name = "swap";
            start = "-2GiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          }
        ];
      };
    };
    nodev = {
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [ "size=200M" ];
      };
    };
  };
}
