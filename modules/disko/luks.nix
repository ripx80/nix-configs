# do this on a running config without repartitioning
# sgdisk -c 1:disk-disk0-ESP /dev/vda
# sgdisk -c 2:disk-disk0-luks /dev/vda
# sgdisk -c 3:disk-disk0-swap /dev/vda

/*
  docs:
   - https://nixos.wiki/wiki/Full_Disk_Encryption
   - https://shen.hong.io/installing-nixos-with-encrypted-root-partition-and-seperate-boot-partition/
*/

{
  disks ? [ "/dev/sda" ],
  ...
}:
{
  disko.devices = {
    disk.disk0 = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            #start = "0";
            size = "512M";
            #end = "512MiB"; # 512Mib #128MiB
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "noatime"
              ];
            };
          };
          luks = {
            #start = "512MiB";
            end = "-2GiB";
            priority = 2;
            content = {
              type = "luks";
              name = "crypt";
              settings = {
                keyFile = "/dev/sdb";
                keyFileSize = 4096;
                #keyFile = "/key/disk.key"; # dd if=/dev/urandom of=./keyfile0.bin bs=1024 count=4, this will be used by autoinstall and then in the config of the installed system
                # preOpenCommands = ''
                #     mkdir -m 0755 -p /key
                #     sleep 2 # To make sure the usb key has been loaded
                #     test -b /dev/sdb && mount -n -t vfat -o ro /dev/sdb /key || echo "no usb key found"
                # '';
                fallbackToPassword = true; # allow to type in the password
              };

              initrdUnlock = true;

              # default command
              # cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --iter-time 2000 --key-size 256 --pbkdf argon2id --use-urandom --verify-passphrase luksFormat device
              extraFormatArgs = [
                "--key-size 512"
                "--hash sha512"
              ];
              extraOpenArgs = [ "--allow-discards" ]; # this has security implifications on luks
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
                  "/__active" = { };
                  "/__snapshot" = { };
                  "/__active/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                    ];
                  };
                  "/__active/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                    ];
                  };
                  "/__active/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                    ];
                  };
                };
              };
            };
          };
          swap = {
            start = "-2GiB";
            #end = "100%";
            priority = 3;
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
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
