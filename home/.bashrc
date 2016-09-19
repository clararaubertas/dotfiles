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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
    case "$TERM" in
        "dumb")
            PS1="> "
            ;;
        xterm*|rxvt*)
       
            PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
            ;;
        *)
            PS1="> "
            ;;
esac



# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export RSENSE_HOME=/opt/rsense-0.3/

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

alias apt-get="apt-fast"

alias freckle='python .freckle_cli/freckle.py'

alias such=git
alias very=git
alias wow='git status'
alias many='bundle exec cap'
alias corm='crontab'
alias cormtab='crontab'
alias emacs='emacsclient -c'

mymosh() { /usr/bin/mosh "$@" -- screen -dR -s bash -e^Aa;}

alias thrus='dict -d moby-thesaurus'

PATH=$PATH:~/opt/android/tools

export ALTERNATE_EDITOR=emacs EDITOR=emacsclient VISUAL=emacsclient


# set 256 color profile where possible
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
export TERM=xterm-256color
fi

#solar
# set up command prompt
# bash_prompt
# Example:
# nicolas@host: ~/.dotfiles on master [+!?$]
# $
# Screenshot: http://i.imgur.com/DSJ1G.png
# iTerm2 prefs: import Solarized theme (disable bright colors for bold text)
# Color ref: http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
# More tips: http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
prompt_git() {
local s=""
local branchName=""
# check if the current directory is in a git repository
if [ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) == 0 ]; then
# check if the current directory is in .git before running git checks
if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]; then
# ensure index is up to date
git update-index --really-refresh -q &>/dev/null
# check for uncommitted changes in the index
if ! $(git diff --quiet --ignore-submodules --cached); then
s="$s+";
fi
# check for unstaged changes
if ! $(git diff-files --quiet --ignore-submodules --); then
s="$s!";
fi
# check for untracked files
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
s="$s?";
fi
# check for stashed files
if $(git rev-parse --verify refs/stash &>/dev/null); then
s="$s$";
fi
fi
# get the short symbolic ref
# if HEAD isn't a symbolic ref, get the short SHA
# otherwise, just give up
branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
git rev-parse --short HEAD 2> /dev/null || \
printf "(unknown)")"
[ -n "$s" ] && s=" [$s]"
printf "%s" "$1$branchName$s"
else
return
fi
}
set_prompts() {
local black=""
local blue=""
local bold=""
local cyan=""
local green=""
local orange=""
local purple=""
local red=""
local reset=""
local white=""
local yellow=""
local hostStyle=""
local userStyle=""
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
tput sgr0 # reset colors
bold=$(tput bold)
reset=$(tput sgr0)
# Solarized colors
# (https://github.com/altercation/solarized/tree/master/iterm2-colors-solarized#the-values)
black=$(tput setaf 15)
blue=$(tput setaf 33)
cyan=$(tput setaf 37)
green=$(tput setaf 64)
orange=$(tput setaf 166)
purple=$(tput setaf 125)
red=$(tput setaf 124)
white=$(tput setaf 0)
yellow=$(tput setaf 136)
 else
bold=""
reset="\e[0m"
black="\e[0;30m"
blue="\e[1;34m"
cyan="\e[1;36m"
green="\e[1;32m"
orange="\e[1;33m"
purple="\e[1;35m"
red="\e[1;31m"
white="\e[1;37m"
yellow="\e[1;33m"
fi                              
# build the prompt
# logged in as root
if [[ "$USER" == "root" ]]; then
userStyle="\[$bold$red\]"
else
userStyle="\[$orange\]"
fi
# connected via ssh
if [[ "$SSH_TTY" ]]; then
hostStyle="\[$bold$red\]"
else
hostStyle="\[$yellow\]"
fi

# set the terminal title to the current working directory
#PS1="\[\033]0;\w\007\]"
PROMPT_COMMAND='echo -ne "\033];${USER}@${HOSTNAME}: ${PWD}\007"'

PS1="\n" # newline
PS1+="$userStyle\u" # username
PS1+="$black@"
PS1+="$hostStyle\h" # host
PS1+="$black: "
PS1+="\[$green\]\w" # working directory
PS1+="\$(prompt_git \"$black on $cyan\")" # git repository details
PS1+="\n"
PS1+="\[$black\]\$ \[$reset\]" # $ (and reset color)
export PS1
}
set_prompts
unset set_prompts

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
