#!/usr/bin/env bash

# nix macos workaround for home-manager
#if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]
#  then
    # shellcheck disable=SC1091
#    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
#fi
# bash depication warining on mac
# remove: 'The default interactive shell is now zsh.'
export BASH_SILENCE_DEPRECATION_WARNING=1