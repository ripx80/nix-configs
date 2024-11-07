#!/usr/bin/env bash

alias nix-clear="nix-collect-garbage -d"
alias nix-system='nix-store -q --references /var/run/current-system/sw | cut -d'-' -f2-'