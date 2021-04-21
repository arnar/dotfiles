#!/usr/bin/zsh

# Keymaps
setxkbmap -option
setxkbmap -option ctrl:nocaps

# On thinkpad
builtin_kbd=$(xinput -list | grep 'AT Translated Set 2 keyboard' | sed -rn 's/.*id=([[:digit:]]+).*/\1/p')
if [[ ! -z $builtin_kbd ]]; then
    setxkbmap -device $builtin_kbd -option altwin:swap_alt_win
fi

# Cycle compton
pkill compton
compton --config $HOME/.dotfiles/compton.conf &

# Restart polybar
polybar-msg cmd restart

# Restart xmonad
xmonad --restart

# Set bg as saved by previous feh command
$HOME/.fehbg
