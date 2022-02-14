#!/usr/bin/zsh

# Keymaps
setxkbmap -option ctrl:nocaps,altwin:swap_alt_win,compose:ralt

# Cycle compton
pkill picom
picom --config $HOME/.dotfiles/compton.conf &

# Restart polybar
polybar-msg cmd restart

# Restart xmonad
xmonad --restart

# Set bg as saved by previous feh command
$HOME/.fehbg
