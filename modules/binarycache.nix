{
  config,
  pkgs,
  lib,
  ...
}:
{ }
/*
  # do this in a extra module
       # add binary cache (substituter)
       # trusted-substituters = ssh://192.168.1.80
       # substituters = ssh://192.168.1.80

       [doc](https://nixos.wiki/wiki/Binary_Cache)
       - nix-serve used binary cache protocol via HTTP on port 5000 default.
       - need signing pub/priv keys
       - only serving ipv4 (ipv6 need redirecting)
       - you can use https with a redirect ssl offload on the webserver
       - check: curl http://binarycache.example.com/nix-cache-info
       - check if content is there: curl https://fzakaria.cachix.org/949dxjmz632id67hjic04x6f3ljldzxh.narinfo
           - or with nix path-info -r /nix/store/sb7nbfcc1ca6j0d0v18f7qzwlsyvi8fz-ocaml-4.10.0 --store https://cache.nixos.org/
       - temp use: nix-store -r /nix/store/gdh8165b7rg4y53v64chjys7mbbw89f9-hello-2.10 --option substituters http://binarycache.example.com --option trusted-public-keys binarycache.example.com:dsafdafDFW123fdasfa123124FADSAD

       - sig with edkey? like the ssh host key?

       # server
           services.nix-serve = {
           enable = true;
           secretKeyFile = "/var/cache-priv-key.pem";
           };

       # client
       nix = {
       settings = {
       substituters = [
           "http://binarycache.example.com"
           "https://nix-community.cachix.org"
           "https://cache.nixos.org/"
       ];
       trusted-public-keys = [
           "binarycache.example.com-1:dsafdafDFW123fdasfa123124FADSAD"
           "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
       ];
       };
   };
*/
