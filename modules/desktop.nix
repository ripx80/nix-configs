{
  hardware,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.ripmod.desktop;
  pkgDesc = "enables desktop env";
in
{
  options = {
    ripmod.desktop = {
      enable = mkEnableOption pkgDesc;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # input
      #xorg.xf86inputevdev
      #xorg.xf86inputsynaptics
      xorg.xf86inputlibinput
    ];

    hardware = {
      pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
        support32Bit = true;
        daemon.config = {
          flat-volumes = "no";
        };
      };

      #DRI acceleration
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };

      # Bluetooth
      # https://nixos.wiki/wiki/Bluetooth
      bluetooth = {
        enable = true;
        # For Bose QC 35
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
      autorun = false;
      exportConfiguration = true;
      xkb = {
        variant = "nodeadkeys";
        options = "";
        layout = "de";
      };
    };
    # Enable touchpad support.
    services.libinput.enable = true;
  };
}

# todo: check this, defined in desktop.nix
#   ### Sound ###
#   # https://nixos.wiki/wiki/PipeWire
#   # rtkit is optional but recommended
#   security.rtkit.enable = true;
#   services.pipewire = {
#     enable = true;
#     alsa.enable = true;
#     alsa.support32Bit = true;
#     pulse.enable = true;
#   # Uncomment to use JACK applications:
#   # jack.enable = true;
#   };
