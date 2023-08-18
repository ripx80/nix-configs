/* generic virtualisation configs without bootloader
    options listed here:
    https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix
*/
{ config, pkgs, lib, inputs, ... }:
with lib; {
  #   imports = [
  #     #"${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  #     "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" # disable if you use vmVariant
  #   ];

  #services.qemuGuest.enable = true;
  #services.xserver.videoDrivers = [ "qxl" ];
  #services.spice-vdagentd.enable = true; # todo: test

  # this will import qemu-vm.nix instead
  virtualisation.vmVariant.virtualisation = {
    graphics = lib.mkForce
      false; # Make VM output to the terminal instead of a separate window
    diskSize = 10000; # MB
    memorySize = 4096; # MB
    cores = 4;
    forwardPorts = [{
      from = "host";
      host.port = 2222;
      guest.port = 22;
    }];
    qemu = {
      options = [
        "-cpu kvm64"
        "-net nic" # add predictable interface names
        "-bios"
        "${pkgs.OVMF.fd}/FV/OVMF.fd"
      ];
    };
    # writableStore = false; # false: you canot build in vm itself and write to store
    # useBootLoader = true; # use the bootloader if true
    # useEFIBoot = true;
    # bios = # null: default is qemu seabios

    # useNixStoreImage # can create a nix store image:
    # bootDevice
    # diskImage
  };

  # need here because we dont have a correct grub boot setup.
  boot.loader.grub.enable = mkForce false;
  boot.loader.systemd-boot.enable = mkForce false;

  # overwrie here config settings for vm use
  services.timesyncd.enable = mkForce false;

  #boot.growPartition = true;

  networking = { interfaces = mkForce { eth0.useDHCP = true; }; };
  # desktop
  #     environment.systemPackages = with pkgs; [
  #         xorg.xf86videovboxvideo
  #     ];
  #     services.xserver = {
  #     videoDrivers = [ "virtualbox" ];
  #     resolutions = [
  #       { x = 1280; y = 720; }
  #       { x = 1920; y = 1080; }
  #       { x = 2560; y = 1440; }
  #     ];
  #   };
}
