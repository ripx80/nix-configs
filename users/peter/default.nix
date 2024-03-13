{ config, pkgs, lib, pub, inputs, system, ... }:
let
  isDarwin = system:
    (builtins.elem system
      inputs.nixpkgs.lib.platforms.darwin); # double move to lib?
in {
  # add user peter secrets
  home-manager.users.peter = (import ./home.nix);

  # good idea here?
  users.users = (if !isDarwin system then {
    peter = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "video" "audio" "tty" "input" "users" ];
      shell = pkgs.bash;
      #openssh.authorizedKeys.keys = pub.rip;
      #hashedPasswordFile = "/run/secrets/rip";
    };
  } else {
    # nixDarwin has no config options
    peter = { shell = pkgs.bash; };
  });
}
