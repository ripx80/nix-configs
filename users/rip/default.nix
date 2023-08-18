{ config, pkgs, lib, pub, inputs, system, ... }:
let
  isDarwin = system:
    (builtins.elem system
      inputs.nixpkgs.lib.platforms.darwin); # double move to lib?
in {
  # add user rip secrets
  home-manager.users.rip = (import ./home.nix);
  home-manager.verbose = true;

  # good idea here?
  users.users = (if !isDarwin system then { # not working
    rip = {
      isNormalUser = true;
      group = "users";
      extraGroups =
        [ "wheel" "nix" "docker" "video" "audio" "tty" "input" "disk" "users" ]
        ++ pkgs.lib.optionals config.programs.wireshark.enable [ "wireshark" ];
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = pub.rip;
      passwordFile = "/run/secrets/rip";
    };
  } else {
    rip = {
      shell = pkgs.bash;
      name = "rip";
      home = "/Users/rip";
    };
  });
}
