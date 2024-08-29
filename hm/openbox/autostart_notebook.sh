#!/bin/bash
#xrandr -s 3440x1440
xhost +local:docker # switch to env vars docker
# if [ "$HOSTNAME" == "ripbox" ]
#   then
# xrandr --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --mode 1680x1050 --pos 1920x0 --rotate normal --left-of HDMI-0
# fi
if [ "$DISPLAY" == ":0.0" ]
  then
	xcompmgr -d:0.0 -F &
	hsetroot -fill ~/bg.jpg &
	(conky) &
    #xmodmap ~/.Xmodmap
#	pulseaudio --start
fi
