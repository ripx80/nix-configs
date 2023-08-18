{ config, lib, pkgs, programs, ... }:

with lib;
let cfg = config.ripmod.bash;
in {
  options = { ripmod.bash.enable = mkEnableOption "Bash"; };
  config = mkIf cfg.enable {
    home.file.".config/bash/vault.sh".source = ./vault.sh;
    home.file.".config/bash/alias.sh".source = ./alias.sh;
    home.file.".config/bash/k8s.sh".source = ./k8s.sh;
    home.file.".config/bash/git.sh".source = ./git.sh;
    home.file.".config/bash/go.sh".source = ./go.sh;
    home.file.".config/bash/mac.sh".source = ./mac.sh;
    home.file.".config/bash/docker.sh".source = ./docker.sh;
    programs.bash = {
      enable = true;
      initExtra = (builtins.readFile ./bashrc);
      # turn off the automated completion injection, need for macos workaround with completions
      enableCompletion = false;
      bashrcExtra = ''
        if [[ -z BASH_COMPLETION_VERSINFO ]]; then
          . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
        fi
      '';

      shellOptions = [
        # ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"]; # default
        # Append to history file rather than replacing it.
        "histappend"
        # check the window size after each command and, if
        # necessary, update the values of LINES and COLUMNS.
        "checkwinsize"
        # Extended globbing.
        "extglob"
      ];
    };

  };
}
