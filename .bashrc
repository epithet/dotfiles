function append_to_path() {
    PATH=${PATH:+':'$PATH':'}
    PATH=${PATH/':'$1':'/':'}
    PATH="$PATH$1"
    PATH=${PATH#':'}
    PATH=${PATH%':'}
}
append_to_path "~/bin"

alias dots="git --git-dir ~/.dotfiles --work-tree ~"
. /run/current-system/sw/share/bash-completion/completions/git
eval "$(complete -p |awk '/ git$/{sub(/ git$/," dots");print}')"

alias forgetpws="systemctl --user stop gpg-agent"
alias ..="cd .."
alias ls="lsd"
alias l.="lsd -d .*"
alias lt="lsd -l --total-size"
alias tree="lsd --tree --icon=always"
alias less="less -S"
alias grep="grep --color=auto"
alias info="info --vi-keys"

export HISTCONTROL=ignorespace:ignoredups

eval "$(starship init bash)"
