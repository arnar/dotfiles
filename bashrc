# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
# xterm-color)
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#     ;;
# *)
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#     ;;
# esac

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Prompt is set later in this file

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# compleat, completion for humans
source /usr/local/share/compleat-1.0/compleat_setup

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Fancy prompt stuff

# Version control msgs from +
# http://ciaranm.wordpress.com/2008/07/16/git-and-subversion-information-in-the-bash-prompt/
ps_scm_f() {
    local s=
    if [[ -d ".svn" ]] ; then
        local r=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p' )
        s="(r$r$(svn status | grep -q -v '^?' && echo -n "*" ))"
    else
        local d=$(git rev-parse --git-dir 2>/dev/null ) b= r= a=
        if [[ -n "${d}" ]] ; then
            if [[ -d "${d}/../.dotest" ]] ; then
                if [[ -f "${d}/../.dotest/rebase" ]] ; then
                    r="rebase"
                elif [[ -f "${d}/../.dotest/applying" ]] ; then
                    r="am"
                else
                    r="???"
                fi
                b=$(git symbolic-ref HEAD 2>/dev/null )
            elif [[ -f "${d}/.dotest-merge/interactive" ]] ; then
                r="rebase-i"
                b=$(<${d}/.dotest-merge/head-name)
            elif [[ -d "${d}/../.dotest-merge" ]] ; then
                r="rebase-m"
                b=$(<${d}/.dotest-merge/head-name)
            elif [[ -f "${d}/MERGE_HEAD" ]] ; then
                r="merge"
                b=$(git symbolic-ref HEAD 2>/dev/null )
            elif [[ -f "${d}/BISECT_LOG" ]] ; then
                r="bisect"
                b=$(git symbolic-ref HEAD 2>/dev/null )"???"
            else
                r=""
                b=$(git symbolic-ref HEAD 2>/dev/null )
            fi

            if git status | grep -q '^# Changed but not updated:' ; then
                a="${a}*"
            fi

            if git status | grep -q '^# Changes to be committed:' ; then
                a="${a}+"
            fi

            if git status | grep -q '^# Untracked files:' ; then
                a="${a}?"
            fi

            b=${b#refs/heads/}
            b=${b// }
            [[ -n "${r}${b}${a}" ]] && s="(${r:+${r}:}${b}${a:+ ${a}})"
        fi
    fi
    s="${s}${ACTIVE_COMPILER}"
    #s="${s:+${s} }"
    echo -n "$s"
}

# Horrible horrible path shortening by me
# .. works like I want it, so stick your *cough*uglycode*cough* remarks
bash_prompt_command() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=25
    local pwd=${PWD/#$HOME/\~}
    local prevpwd=${pwd}
    local truncations=0
    while [ "${#pwd}" -gt "$pwdmaxlen" ]; do
        prevpwd=$pwd
        pwd=$(echo $pwd | sed 's/\/\(.\)[^\/]\+\//\/\1\//')
        if [ "$pwd" = "$prevpwd" ]; then 
            break; 
        else
            truncations=$((truncations + 1))
        fi
    done
    # Indicate that there has been dir truncation
    NEW_PWD=$pwd
    NEW_PWD_REST=${NEW_PWD}
    NEW_PWD_TRUNC=""
    if [ "$truncations" -gt "0" ]; then
        if [ "${pwd:0:1}" = '~' ]; then
            NEW_PWD_TRUNC=${pwd:0:$(($truncations * 2 + 2))}
            NEW_PWD_REST=${pwd:$(($truncations * 2 + 2))}
        else
            NEW_PWD_TRUNC=${pwd:0:$(($truncations * 2 + 1))}
            NEW_PWD_REST=${pwd:$(($truncations * 2 + 1))}
        fi
    fi
}

bash_prompt() {
    case $TERM in
     xterm*|rxvt*)
         local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
          ;;
     *)
         local TITLEBAR=""
          ;;
    esac
    local NONE="\[\033[0m\]"    # unsets color to term's fg color
    
    # regular colors
    local K="\[\033[0;30m\]"    # black
    local R="\[\033[0;31m\]"    # red
    local G="\[\033[0;32m\]"    # green
    local Y="\[\033[0;33m\]"    # yellow
    local B="\[\033[0;34m\]"    # blue
    local M="\[\033[0;35m\]"    # magenta
    local C="\[\033[0;36m\]"    # cyan
    local W="\[\033[0;37m\]"    # white
    
    # emphasized (bolded) colors
    local EMK="\[\033[1;30m\]"
    local EMR="\[\033[1;31m\]"
    local EMG="\[\033[1;32m\]"
    local EMY="\[\033[1;33m\]"
    local EMB="\[\033[1;34m\]"
    local EMM="\[\033[1;35m\]"
    local EMC="\[\033[1;36m\]"
    local EMW="\[\033[1;37m\]"
    
    # background colors
    local BGK="\[\033[40m\]"
    local BGR="\[\033[41m\]"
    local BGG="\[\033[42m\]"
    local BGY="\[\033[43m\]"
    local BGB="\[\033[44m\]"
    local BGM="\[\033[45m\]"
    local BGC="\[\033[46m\]"
    local BGW="\[\033[47m\]"
    
    local UC=$W                 # user's color
    [ $UID -eq "0" ] && UC=$R   # root's color

    PS1="\${debian_chroot:+(\$debian_chroot)}${G}\u@\h${NONE}:${B}\${NEW_PWD_TRUNC}${EMB}\${NEW_PWD_REST}$C\$(ps_scm_f)${NONE}\$ "
    #PS1="$TITLEBAR ${EMK}[${UC}\u${EMK}@${UC}\h ${EMB}\${NEW_PWD}${EMK}]${UC}\\$ ${NONE}"
    # without colors: PS1="[\u@\h \${NEW_PWD}]\\$ "
    # extra backslash in front of \$ to make bash colorize the prompt
}

PROMPT_COMMAND=bash_prompt_command
bash_prompt
unset bash_prompt

# GO (Issue9) stuff
export GOROOT=$HOME/go
export GOOS=linux
export GOARCH=386

function shareit { 
    scp $1 blackhole.hvergi.net:/home/arnar/public_html; 
    echo "http://www.hvergi.net/arnar/public/$(basename $1)" | xclip ; 
}

echo
fortune
echo

