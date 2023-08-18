# Dual booting with other operating systems is not supported.
# only efi is supported here
# todo: check if dev/disk/by-id working
{ disks ? [ "/dev/sda" ], ... }: {
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
              mountpoint = "/boot";
              mountOptions = [ "defaults" "noatime" ];
            };
          }
          {
            name = "root";
            start = "512MiB";
            end = "-2GiB";

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
                  #mountOptions =
                  #  [ "noauto" "compress=zstd" "noatime" "autodefrag" ];

                };
                "/__snapshot" = {
                  #mountOptions =
                  #  [ "noauto" "compress=zstd" "noatime" "autodefrag" ];
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
                # use tmpfs as /tmp
                #   "/__active/tmp" = {
                #     mountpoint = "/tmp";
                #     mountOptions = [ "compress=zstd" "noatime" "autodefrag" ];
                #   };

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
