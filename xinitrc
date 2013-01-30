#!/bin/zsh
xsetroot -cursor_name left_ptr
feh --bg-fill ~/Pictures/desktop-snowroad.png
setxkbmap -model pc -layout "us,is,se" -variant "altgr-intl,," -option "caps:swapescape,grp:sclk_toggle"
dzen2 -x 0 -y 0 -h 20 -bg \#434541 &
trayer --edge top --align right --SetPartialStrut true --transparent true --tint '0x434541' --alpha 0 --height 20 --widthtype request &
LANG=is_IS.UTF-8 conky | dzen2 -x 1400 -y 3 -h 15 -w 450 -ta r -fg \#cccccc -bg \#434541 -fn 'Droid Sans Mono-10'
exec xmonad

