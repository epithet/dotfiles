umask 027

function append_to_path() {
    PATH=${PATH:+':'$PATH':'}
    PATH=${PATH/':'$1':'/':'}
    PATH="$PATH$1"
    PATH=${PATH#':'}
    PATH=${PATH%':'}
}
append_to_path ~/bin # ~ must be expanded for git-* extension commands

alias dots="git --git-dir ~/.dotfiles --work-tree ~"
alias stod="GIT_DIR=~/.dotfiles tig"
. /run/current-system/sw/share/bash-completion/completions/git
eval "$(complete -p |awk '/ git$/{sub(/ git$/," dots");print}')"

. ~/bin/dobackup.completion

alias forgetpws="systemctl --user stop gpg-agent"
alias ..="cd .."
alias ls="lsd --color=auto" # for --color=always use `lsd`
alias l.="lsd --color=auto -d .*"
alias lt="lsd --color=auto -l --total-size"
alias tree="lsd --tree --icon=always"
alias less="less -S"
alias grep="grep --color=auto"
alias mutt="neomutt"
if [ -r ~/.config/neomutt/accounts.sh ]; then
    . ~/.config/neomutt/accounts.sh
fi

bind -x '"":"tmux-sessionizer"'

export HISTCONTROL=ignorespace:ignoredups

eval "$(starship init bash)"
