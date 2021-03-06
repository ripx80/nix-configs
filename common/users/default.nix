{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];
  environment.systemPackages = with pkgs; [
      home-manager
  ];
    users.motd = "
#`````````` ___    ____    ____
#````______/```\__//```\__/____\
#``_/```\_/``:```````````//____ \
#`/|``````:``:``..``````/````````\   Host: 	    $HOSTNAME
#|`|`````::`````::``````\````````/   Admin: 	rip
#|`|`````:|`````||`````\`\______/    Contact:	hellme
#|`|`````||`````||``````|\``/``|
#`\|`````||`````||``````|```/`|`\
#``|`````||`````||``````|``/`/_\`\
#``|`___`||`___`||``````|`/``/````\
#```\_-_/``\_-_/`|`____`|/__/``````\	Be careful what you do...
#````````````````_\_--_/````\`````/
#```````````````/____```````````/	    we are watching you!
#``````````````/`````\`````````/
#``````````````\______\_______/
";

  users.users.rip = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" "audio" "tty" "input" "users"];
    shell = pkgs.bash;
    #shell = pkgs.nushell;
  };
  home-manager.users.rip = (import ./rip/home.nix);
}