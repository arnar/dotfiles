
        # don't set prompt if this is not interactive shell
        [[ $- != *i* ]]  &&  return

###################################################################   CONFIG

        #####  read config file if any.

        unset   dir_color rc_color user_id_color root_id_color init_vcs_color clean_vcs_color
        unset modified_vcs_color added_vcs_color addmoded_vcs_color untracked_vcs_color op_vcs_color detached_vcs_color

        conf=git-prompt.conf;                   [[ -r $conf ]]  && . $conf
        conf=/etc/git-prompt.conf;              [[ -r $conf ]]  && . $conf
        conf=~/.git-prompt.conf;                [[ -r $conf ]]  && . $conf
        conf=~/.config/git-prompt.conf;         [[ -r $conf ]]  && . $conf
        unset conf


        #####  set defaults if not set

        git_module=${git_module:-on}
        svn_module=${svn_module:-off}
        hg_module=${hg_module:-on}
        vim_module=${vim_module:-on}
        error_bell=${error_bell:-off}
        cwd_cmd=${cwd_cmd:-\\w}

        #### vcs state colors
                 init_vcs_color=${init_vcs_color:-WHITE}        # initial
                clean_vcs_color=${clean_vcs_color:-blue}        # nothing to commit (working directory clean)
             modified_vcs_color=${modified_vcs_color:-red}      # Changed but not updated:
                added_vcs_color=${added_vcs_color:-green}       # Changes to be committed:
             addmoded_vcs_color=${addmoded_vcs_color:-yellow}
            untracked_vcs_color=${untracked_vcs_color:-BLUE}    # Untracked files:
                   op_vcs_color=${op_vcs_color:-MAGENTA}
             detached_vcs_color=${detached_vcs_color:-RED}

#####################################################################  post config

        ################# make PARSE_VCS_STATUS
        unset PARSE_VCS_STATUS
        [[ $git_module = "on" ]]   &&   type git >&/dev/null   &&   PARSE_VCS_STATUS+="parse_git_status"
        [[ $svn_module = "on" ]]   &&   type svn >&/dev/null   &&   PARSE_VCS_STATUS+="${PARSE_VCS_STATUS+||}parse_svn_status"
        [[ $hg_module  = "on" ]]   &&   type hg  >&/dev/null   &&   PARSE_VCS_STATUS+="${PARSE_VCS_STATUS+||}parse_hg_status"
                                                                    PARSE_VCS_STATUS+="${PARSE_VCS_STATUS+||}return"
        ################# terminfo colors-16
        #
        #       black?    0 8
        #       red       1 9
        #       green     2 10
        #       yellow    3 11
        #       blue      4 12
        #       magenta   5 13
        #       cyan      6 14
        #       white     7 15
        #
        #       terminfo setaf/setab - sets ansi foreground/background
        #       terminfo sgr0 - resets all attributes
        #       terminfo colors - number of colors
        #
        #################  Colors-256
        #  To use foreground and background colors:
        #       Set the foreground color to index N:    \033[38;5;${N}m
        #       Set the background color to index M:    \033[48;5;${M}m
        # To make vim aware of a present 256 color extension, you can either set
        # the $TERM environment variable to xterm-256color or use vim's -T option
        # to set the terminal. I'm using an alias in my bashrc to do this. At the
        # moment I only know of two color schemes which is made for multi-color
        # terminals like urxvt (88 colors) or xterm: inkpot and desert256,

            black="\[\033[0;30m\]"    # black
            red="\[\033[0;31m\]"    # red
            green="\[\033[0;32m\]"    # green
            yellow="\[\033[0;33m\]"    # yellow
            blue="\[\033[0;34m\]"    # blue
            magenta="\[\033[0;35m\]"    # magenta
            cyan="\[\033[0;36m\]"    # cyan
            white="\[\033[0;37m\]"    # white
            
            # emphasized (bolded) colors
            BLACK="\[\033[1;30m\]"
            RED="\[\033[1;31m\]"
            GREEN="\[\033[1;32m\]"
            YELLOW="\[\033[1;33m\]"
            BLUE="\[\033[1;34m\]"
            MAGENTA="\[\033[1;35m\]"
            CYAN="\[\033[1;36m\]"
            WHITE="\[\033[1;37m\]"

            colors_reset="\[\033[0m\]"    # unsets color to term's fg color
    

        # replace symbolic colors names to raw treminfo strings
                 init_vcs_color=${!init_vcs_color}
             modified_vcs_color=${!modified_vcs_color}
            untracked_vcs_color=${!untracked_vcs_color}
                clean_vcs_color=${!clean_vcs_color}
                added_vcs_color=${!added_vcs_color}
                   op_vcs_color=${!op_vcs_color}
             addmoded_vcs_color=${!addmoded_vcs_color}
             detached_vcs_color=${!detached_vcs_color}

parse_svn_status() {

        [[   -d .svn  ]] || return 1

        vcs=svn

        ### get rev
        eval `
            svn info |
                sed -n "
                    s@^URL[^/]*//@repo_dir=@p
                    s/^Revision: /rev=/p
                "
        `
        ### get status

        unset status modified added clean init added mixed untracked op detached
        eval `svn status 2>/dev/null |
                sed -n '
                    s/^A...    \([^.].*\)/modified=modified;             modified_files[${#modified_files[@]}]=\"\1\";/p
                    s/^M...    \([^.].*\)/modified=modified;             modified_files[${#modified_files[@]}]=\"\1\";/p
                    s/^\?...    \([^.].*\)/untracked=untracked;  untracked_files[${#untracked_files[@]}]=\"\1\";/p
                '
        `
        # TODO branch detection if standard repo layout

        [[  -z $modified ]]   &&  [[ -z $untracked ]]  &&  clean=clean
        vcs_info=r
        vcs_rev=$rev
 }

parse_hg_status() {

        # ☿

        [[  -d ./.hg/ ]]  ||  return  1

        vcs=hg

        ### get status
        unset status modified added clean init added mixed untracked op detached

        eval `hg status 2>/dev/null |
                sed -n '
                        s/^M \([^.].*\)/modified=modified; modified_files[${#modified_files[@]}]=\"\1\";/p
                        s/^A \([^.].*\)/added=added; added_files[${#added_files[@]}]=\"\1\";/p
                        s/^R \([^.].*\)/added=added;/p
                        s/^! \([^.].*\)/modified=modified;/p
                        s/^? \([^.].*\)/untracked=untracked; untracked_files[${#untracked_files[@]}]=\\"\1\\";/p
        '`

        branch=`hg branch 2> /dev/null`

        [[ -z $modified ]]   &&   [[ -z $untracked ]]   &&   [[ -z $added ]]   &&   clean=clean
        vcs_info=$branch
        vcs_rev=""
 }



parse_git_status() {

        # TODO add status: LOCKED (.git/index.lock)

        git_dir=`[[ $git_module = "on" ]]  &&  git rev-parse --git-dir 2> /dev/null`
        #git_dir=`eval \$$git_module  git rev-parse --git-dir 2> /dev/null`
        #git_dir=` git rev-parse --git-dir 2> /dev/null`

        [[  -n ${git_dir/./} ]]   ||   return  1

        vcs=git

        ##########################################################   GIT STATUS
	file_regex='\([^/ ]*\/\{0,1\}\).*'
	added_files=()
	modified_files=()
	untracked_files=()
        unset branch status modified added clean init added mixed untracked op detached

	# quoting hell
        eval " $(
                git status 2>/dev/null |
                    sed -n '
                        s/^# On branch /branch=/p
                        s/^nothing to commit (working directory clean)/clean=clean/p
                        s/^# Initial commit/init=init/p

                        /^# Changes to be committed:/,/^# [A-Z]/ {
                            s/^# Changes to be committed:/added=added;/p

                            s/^#	modified:   '"$file_regex"'/	[[ \" ${added_files[*]} \" =~ \" \1 \" ]] || added_files[${#added_files[@]}]=\"\1\"/p
                            s/^#	new file:   '"$file_regex"'/	[[ \" ${added_files[*]} \" =~ \" \1 \" ]] || added_files[${#added_files[@]}]=\"\1\"/p
                            s/^#	renamed:[^>]*> '"$file_regex"'/	[[ \" ${added_files[*]} \" =~ \" \1 \" ]] || added_files[${#added_files[@]}]=\"\1\"/p
                            s/^#	copied:[^>]*> '"$file_regex"'/ 	[[ \" ${added_files[*]} \" =~ \" \1 \" ]] || added_files[${#added_files[@]}]=\"\1\"/p
                        }

                        /^# Changed but not updated:/,/^# [A-Z]/ {
                            s/^# Changed but not updated:/modified=modified;/p
                            s/^#	modified:   '"$file_regex"'/	[[ \" ${modified_files[*]} \" =~ \" \1 \" ]] || modified_files[${#modified_files[@]}]=\"\1\"/p
                            s/^#	unmerged:   '"$file_regex"'/	[[ \" ${modified_files[*]} \" =~ \" \1 \" ]] || modified_files[${#modified_files[@]}]=\"\1\"/p
                        }

                        /^# Untracked files:/,/^[^#]/{
                            s/^# Untracked files:/untracked=untracked;/p
                            s/^#	'"$file_regex"'/		[[ \" ${untracked_files[*]} ${modified_files[*]} ${added_files[*]} \" =~ \" \1 \" ]] || untracked_files[${#untracked_files[@]}]=\"\1\"/p
                        }
                    '
        )"

        if  ! grep -q "^ref:" $git_dir/HEAD  2>/dev/null;   then
                detached=detached
        fi


        #################  GET GIT OP

        unset op

        if [[ -d "$git_dir/.dotest" ]] ;  then

                if [[ -f "$git_dir/.dotest/rebasing" ]] ;  then
                        op="rebase"

                elif [[ -f "$git_dir/.dotest/applying" ]] ; then
                        op="am"

                else
                        op="am/rebase"

                fi

        elif  [[ -f "$git_dir/.dotest-merge/interactive" ]] ;  then
                op="rebase -i"
                # ??? branch="$(cat "$git_dir/.dotest-merge/head-name")"

        elif  [[ -d "$git_dir/.dotest-merge" ]] ;  then
                op="rebase -m"
                # ??? branch="$(cat "$git_dir/.dotest-merge/head-name")"

        # lvv: not always works. Should  ./.dotest  be used instead?
        elif  [[ -f "$git_dir/MERGE_HEAD" ]] ;  then
                op="merge"
                # ??? branch="$(git symbolic-ref HEAD 2>/dev/null)"

        elif  [[ -f "$git_dir/index.lock" ]] ;  then
                op="locked"

        else
                [[  -f "$git_dir/BISECT_LOG"  ]]   &&  op="bisect"
                # ??? branch="$(git symbolic-ref HEAD 2>/dev/null)" || \
                #    branch="$(git describe --exact-match HEAD 2>/dev/null)" || \
                #    branch="$(cut -c1-7 "$git_dir/HEAD")..."
        fi


        ####  GET GIT HEX-REVISION
        rawhex=`git rev-parse HEAD 2>/dev/null`
        rawhex=${rawhex/HEAD/}
        rawhex=${rawhex:0:6}

        #### branch
        #branch=${branch/master/M}

                        # another method of above:
                        # branch=$(git symbolic-ref -q HEAD || { echo -n "detached:" ; git name-rev --name-only HEAD 2>/dev/null; } )
                        # branch=${branch#refs/heads/}

        ### compose vcs_info

        if [[ $init ]];  then 
                vcs_info=${white}init
                vcs_rev=""

        else
                if [[ "$detached" ]] ;  then
                        branch="<detached:`git name-rev --name-only HEAD 2>/dev/null`"


                elif   [[ "$op" ]];  then
                        branch="$op:$branch"
                        if [[ "$op" == "merge" ]] ;  then
                            branch+="<--$(git name-rev --name-only $(<$git_dir/MERGE_HEAD))"
                        fi
                        #branch="<$branch>"
                fi
                vcs_info="$branch="
                vcs_rev="$rawhex"

        fi
 }


parse_vcs_status() {

        unset   file_list modified_files untracked_files added_files
        unset   vcs vcs_info vcs_rev
        unset   status modified untracked added init detached
        unset   file_list modified_files untracked_files added_files
        unset   vim_files

        [[ $vcs_ignore_dir_list =~ $PWD ]] && return

        eval   $PARSE_VCS_STATUS

        ### status:  choose primary (for branch color)
        unset status
        status=${op:+op}
        status=${status:-$detached}
        status=${status:-$clean}
        status=${status:-$modified}
        status=${status:-$added}
        status=${status:-$untracked}
        status=${status:-$init}
                                # at least one should be set
                                : ${status?prompt internal error: git status}
        eval vcs_color="\${${status}_vcs_color}"
                                # no def:  vcs_color=${vcs_color:-$WHITE}    # default


        ### VIM

        if  [[ $vim_module = "on" ]] ;  then
                # equivalent to vim_glob=`ls .*.vim`  but without running ls
                unset vim_glob vim_file vim_files
                old_nullglob=`shopt -p nullglob`
                    shopt -s nullglob
                    vim_glob=`echo .*.sw?`
                eval $old_nullglob

                if [[ $vim_glob ]];  then
                    vim_file=${vim_glob#.}
                    vim_file=${vim_file/.sw?/}
                    # if swap is newer,  then this is unsaved vim session
                    #[[ .${vim_file}.swp -nt $vim_file ]]  && vim_files=$vim_file
                    # [temoto custom] if swap is older, then it must be deleted, so show all swaps.
                    vim_files=$vim_file
                fi
        fi


        ### file list
        unset file_list
        [[ ${added_files[0]}     ]]  &&  file_list+=$vcs_color" "$added_vcs_color${#added_files[@]}
        [[ ${modified_files[0]}  ]]  &&  file_list+=$vcs_color" "$modified_vcs_color${#modified_files[@]}
        [[ ${untracked_files[0]} ]]  &&  file_list+=$vcs_color" "$untracked_vcs_color${#untracked_files[@]}
        [[ ${vim_files}          ]]  &&  file_list+=$vcs_color" "${RED}vim:${vim_files}
        file_list=${file_list:+$file_list}

        echo -n "$cyan($vcs_info$vcs_color$vcs_rev$cyan${file_list}$cyan)"

        ### fringes
        #head_local="${head_local+$vcs_color$head_local }"
        #above_local="${head_local+$vcs_color$head_local\n}"
        #tail_local="${tail_local+$vcs_color $tail_local}${dir_color}"
 }

        #PROMPT_COMMAND=prompt_command_function

        #enable_set_shell_label

        unset rc id tty modified_files file_list

# vim: set ft=sh ts=8 sw=8 et:
