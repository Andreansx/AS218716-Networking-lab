# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then

    # basic colors
    C_RESET='\[\033[0m\]'
    C_BLACK='\[\033[0;30m\]'
    C_RED='\[\033[0;31m\]'
    C_GREEN='\[\033[0;32m\]'
    C_YELLOW='\[\033[0;33m\]'
    C_BLUE='\[\033[0;34m\]'
    C_MAGENTA='\[\033[0;35m\]'
    C_CYAN='\[\033[0;36m\]'
    C_WHITE='\[\033[0;37m\]'

    # bold or bright colors
    C_B_BLACK='\[\033[1;30m\]'
    C_B_RED='\[\033[1;31m\]'
    C_B_GREEN='\[\033[1;32m\]'
    C_B_YELLOW='\[\033[1;33m\]'
    C_B_BLUE='\[\033[1;34m\]'
    C_B_MAGENTA='\[\033[1;35m\]'
    C_B_CYAN='\[\033[1;36m\]'
    C_B_WHITE='\[\033[1;37m\]'

    parse_git_branch() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local branch_name
            branch_name=$(git symbolic-ref --short HEAD 2>/dev/null) || \
            branch_name=$(git rev-parse --short HEAD 2>/dev/null)
            
            if [ -n "$branch_name" ]; then
                echo -e " ${C_B_MAGENTA}(git:${branch_name})${C_RESET}"
            fi
        fi
    }

    set_custom_prompt() {
        local exit_status=$?

        local user_color="${C_B_CYAN}"
        local host_color="${C_B_GREEN}"
        local path_color="${C_B_YELLOW}"
        local prompt_char="❯" # Ładny znak początkowy (możesz zmienić na np. ➜, ▶, ➤)
        local prompt_suffix='\$' # $ dla zwykłego użytkownika, # dla root

        if [ "$(id -u)" -eq 0 ]; then
            user_color="${C_B_RED}"
            host_color="${C_B_RED}" 
            prompt_suffix='#'
        fi

        local status_indicator_color
        if [ $exit_status -eq 0 ]; then
            status_indicator_color="${C_B_GREEN}"
        else
            status_indicator_color="${C_B_RED}"
        fi
        
        local chroot_display=""
        if [ -n "${debian_chroot:-}" ]; then
            chroot_display="(${debian_chroot})"
        fi

        PS1="${chroot_display}"
        PS1+="${user_color}\u${C_RESET}"
        PS1+="${C_WHITE}@${C_RESET}"
        PS1+="${host_color}\h${C_RESET}"
        PS1+="${C_WHITE}:${C_RESET}"
        PS1+="${path_color}\w${C_RESET}"
        PS1+="\$(parse_git_branch)"
        PS1+="\n"

        PS1+="${status_indicator_color}${prompt_char}${prompt_suffix} ${C_RESET}"
    }

    PROMPT_COMMAND=set_custom_prompt

else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
