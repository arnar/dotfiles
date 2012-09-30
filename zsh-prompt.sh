# ZSH Theme

if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

PROMPT='%{$fg[$NCOLOR]%}%n%{$fg[green]%}@%m%{$reset_color%}:${PWD_ABBR}%{$reset_color%}\
$(git_super_status)\
%(!.#.$) '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='$(virtualenv_name)'

virtualenv_name() {
    if [[ -n ${VIRTUAL_ENV} ]]; then
        echo "%{$fg[black]%}[ve:%{$fg_bold[black]%}$(basename ${VIRTUAL_ENV})%{$reset_color$fg[black]%}]%{$reset_color%}"
    fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

#autoload -U colors
#colors

# Allow for functions in the prompt.
#setopt PROMPT_SUBST

autoload -U add-zsh-hook

add-zsh-hook chpwd chpwd_update_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

add-zsh-hook chpwd dir_abbrev

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ -n "$ZSH_THEME_GIT_PROMPT_NOCACHE" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    local gitstatus="$HOME/.dotfiles/gitstatus.py"
    _GIT_STATUS=`python ${gitstatus}`
    __CURRENT_GIT_STATUS=("${(@f)_GIT_STATUS}")
	GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
	GIT_REMOTE=$__CURRENT_GIT_STATUS[2]
	GIT_STAGED=$__CURRENT_GIT_STATUS[3]
	GIT_CONFLICTS=$__CURRENT_GIT_STATUS[4]
	GIT_CHANGED=$__CURRENT_GIT_STATUS[5]
	GIT_UNTRACKED=$__CURRENT_GIT_STATUS[6]
	GIT_CLEAN=$__CURRENT_GIT_STATUS[7]
	GIT_SHA1=$__CURRENT_GIT_STATUS[8]
}

# Update vars now in case shell is started in a git repo
update_current_git_vars

git_super_status() {
	precmd_update_git_vars
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
	  STATUS="($GIT_BRANCH"
	  STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"
	  if [ -n "$GIT_REMOTE" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE$GIT_REMOTE%{${reset_color}%}"
	  fi
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SHA1$GIT_SHA1%{${reset_color}%}"
	  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
	  if [ "$GIT_STAGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
	  fi
	  if [ "$GIT_CONFLICTS" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
	  fi
	  if [ "$GIT_CHANGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED%{${reset_color}%}"
	  fi
	  if [ "$GIT_UNTRACKED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED$GIT_UNTRACKED%{${reset_color}%}"
	  fi
	  if [ "$GIT_CLEAN" -eq "1" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
	  fi
	  STATUS="$STATUS%{${reset_color}%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
	  echo "$STATUS"
	fi
}

# pwd string abbreviation
dir_abbrev() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=25
    if which gsed > /dev/null; then
        local sed="gsed"
    else
        local sed="sed"
    fi
    local pwd=${PWD/#$HOME/\~}
    local prevpwd=${pwd}
    local truncations=0
    while [ "${#pwd}" -gt "$pwdmaxlen" ]; do
        prevpwd=$pwd
        pwd=$(echo $pwd | $sed -E 's/\/(\.?[^.])[^/]+\//\/\1\//')
        if [ "$pwd" = "$prevpwd" ]; then
            break;
        else
            truncations=$((truncations + 1))
        fi
    done
    # Indicate that there has been dir truncation
    local new_pwd_rest=$pwd
    local new_pwd_trunc=""
    if [ "$truncations" -gt "0" ]; then
        if [ "${pwd:0:1}" = '~' ]; then
            new_pwd_trunc=${pwd:0:$(($truncations * 2 + 2))}
            new_pwd_rest=${pwd:$(($truncations * 2 + 2))}
        else
            new_pwd_trunc=${pwd:0:$(($truncations * 2 + 1))}
            new_pwd_rest=${pwd:$(($truncations * 2 + 1))}
        fi
    fi
    local blue=$fg[blue]
    local BLUE=$fg_bold[blue]
    export PWD_ABBR=$blue$new_pwd_trunc$BLUE$new_pwd_rest
}

# Execute the above once to set initial $PWD_ABBR
dir_abbrev

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[cyan]%})%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SEPARATOR=""
ZSH_THEME_GIT_PROMPT_BRANCH=""
ZSH_THEME_GIT_PROMPT_SHA1="%{$fg[black]%}=%{$fg_bold[black]%}"
ZSH_THEME_GIT_PROMPT_STAGED=" %{$fg[green]%}+"
ZSH_THEME_GIT_PROMPT_CONFLICTS=" %{$fg[red]%}✖"
ZSH_THEME_GIT_PROMPT_CHANGED=" %{$fg[red]%}*"
ZSH_THEME_GIT_PROMPT_REMOTE=""
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg_bold[blue]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""


