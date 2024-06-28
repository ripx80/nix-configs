# not tested at the moment
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
            size = "512M";
            #start = "1M";
            #end = "512M"; # 512Mib #128MiB
            #size = "512MiB"; # 512Mib #128MiB
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
          root = {
            #start = "512MiB";
            end = "-2GiB";
            #size = "100%";
            priority = 2;
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
          swap = {
            start = "-2GiB";
            #end = "100%";
            #size = "2GiB";
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
