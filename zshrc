# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
# CASE_SENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
plugins=(vi-mode brew osx pip npm)
source $ZSH/oh-my-zsh.sh

# Vi editing mode
set -o vi

# Set up the prompt with git stuff etc.
source $HOME/.dotfiles/zsh-prompt.sh

export PATH=/usr/local/bin:$HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/texbin

# Linux / mac specific settings
if [ "$(uname)" != "Darwin" ]; then
  # For linux
  alias vol="amixer sset Master"
  alias f="xdg-open"
  alias ack="ack-grep"
  alias vi="vim"
  function shareit { 
    scp $1 blackhole.hvergi.net:/home/arnar/public_html; 
    echo "http://www.hvergi.net/arnar/public/$(basename $1)" | xclip ; 
  }
else
  # for mac
  alias f="open"
  alias vi="mvim"
  export LSCOLORS='ExFxcxdxbxegedabagacad'
fi

function pp {
    pygmentize -g $1 | less -R ;
}

# For python interpreter
export PYTHONSTARTUP=~/.dotfiles/pystartup

# Virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/chalmers
source /usr/local/bin/virtualenvwrapper.sh

# Get smarter every day
echo
fortune
echo
