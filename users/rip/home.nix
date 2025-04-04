{
  config,
  pkgs,
  lib,
  specialArgs,
  ...
}:
with lib;
let
  darwin-pkgs =
    if pkgs.system == "x86_64-darwin" then
      [
        pkgs.vscode
        pkgs.spotify
      ]
    # chrome only available on linux
    else
      [ ];
in
{
  imports = [
    ../../hm # default hm config
    ./bash
    ./tiny
  ];
  ripmod.bash.enable = true;
  ripmod.tiny.enable = true;
  #ripmod.wireshark.enable = true; # very long build times for qt min. 30 minutes, buggy on macos

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  #programs.go.enable = true;

  home.packages =
    with pkgs;
    [
      unzip
      tig
      bat
      fd
      procs
      sd
      du-dust
      ripgrep
      bottom
      bandwhich
      difftastic
      jq
      # grex download from github
      #starship comming soon
      # hyperfine # benchmark
      dogdns
      git-crypt
      # httpie
    ]
    ++ darwin-pkgs;

  # need this file for signing
  home.file.".ssh/allowed_signers".text = "ripx80@protonmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0f8TJ57ydBSCKhsel9YYYcsoAsSjsj8J98bYrP+g33";

  programs.git = {
    enable = true;
    userName = "ripx80";
    userEmail = "ripx80@protonmail.com";
    aliases = {
      permission-reset = ''!git diff -p -R --no-color | grep -E "^(diff|(old|new) mode)" --color=never | git apply'';
    };
    extraConfig = {
      http = {
        sslCAinfo = "/etc/ssl/certs/ca-certificates.crt";
      };
      push = {
        default = "matching";
      };
      pull = {
        rebase = true;
      };
      fetch = {
        prune = true;
      };
      diff.sqlite3 = {
        binary = true;
        textconv = "echo .dump | sqlite3";
        # textconv = "echo .dump | sqlite3" # add this to .gitattributes to see the sqlite3 diff
      };
      core.editor = "nano -w";
      # use different urls with ssh keys, git can swap urls
      # [url "github-plnx:planet-express"]
      #  insteadOf = git@github.com:planet-express

      # Sign all tags and commits using ssh key
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      init.defaultBranch = "master";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # comming in 23.11
  #   programs.eza = {
  #     enable = true;
  #     enableAliases = true;
  #     package = pkgs.unstable.eza;
  #   };

  # extra config for all nixos systems
  # config = {
  #   rip.dev = {
  #     docs.enable = true;
  #     haskell.enable = true;
  #     nodejs.enable = true;
  #     python.enable = true;
  #     shell.enable = true;
  #   };
  # };
}
