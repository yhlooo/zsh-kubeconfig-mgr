# import kcmgr
source "${0:A:h}/kcmgr.zsh"

# kubeconfig prompt info
function kubeconfig_prompt_info() {
    kubeconfig=${KUBECONFIG:-${HOME}/.kube/config}

    if [[ -f $kubeconfig ]]; then
        prompt_color="%{$fg[green]%}"
    else
        prompt_color="%{$fg[red]%}"
    fi

    if [[ "$kubeconfig" == "${HOME}/.kube/config" ]]; then
        kubeconfig_showname="<default>"
    else
        kubeconfig_showname="${kubeconfig#${_kubeconfigs_dir}/}"
    fi

    echo "${prompt_color}${kubeconfig_showname}%{$reset_color%}"
}

# set alias
alias lkc='kcmgr ls'
alias rkc='kcmgr show'
alias skc='kcmgr set'
alias dkc='kcmgr del'
alias ekc='kcmgr edit'
