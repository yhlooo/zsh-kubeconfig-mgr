# init configs dir
_kubeconfigs_dir="${HOME}/.kube/configs"
mkdir -p "$_kubeconfigs_dir"
touch "${_kubeconfigs_dir}/.kcmgr"

# print kcmgr help message
function _kcmgr_help() {
    echo "kcmgr: kubeconfig manager"
    echo
    echo "Usage:"
    echo "  kcmgr [command]"
    echo
    echo "Available Commands:"
    echo "  ls, list     list kubeconfig"
    echo "  show         show content of current or specified kubeconfig"
    echo "  set          set KUBECONFIG environment variable"
    echo "  unset        unset KUBECONFIG environment variable"
    echo "  edit         edit current or specified kubeconfig"
    echo "  del, delete  delete current or specified kubeconfig"
    echo "  help         print this message"
}

# kubeconfig manager
function kcmgr() {
    if [[ $# -lt 1 ]]; then
        _kcmgr_help
        return 1
    fi

    case $1 in
        (ls|list) _kcmgr_list
        ;;
        (show) _kcmgr_show ${@:2}
        ;;
        (set) _kcmgr_set ${@:2}
        ;;
        (unset) _kcmgr_unset
        ;;
        (edit) _kcmgr_edit ${@:2}
        ;;
        (del|delete) _kcmgr_delete ${@:2}
        ;;
        (help) _kcmgr_help
        ;;
        (*) 
            _kcmgr_help
            return 1
        ;;
    esac
}

# kcmgr list
# list kubeconfig
function _kcmgr_list() {
    for f in "${_kubeconfigs_dir}"/(*|.kcmgr); do
        # ignore .kcmgr
        if [[ "$f" == "${_kubeconfigs_dir}/.kcmgr" ]]; then
            continue
        fi

        # trim prefix
        f=${f#"${_kubeconfigs_dir}/"}

        # add prefix, indent
        # TODO: and color
        if [[ "${_kubeconfigs_dir}/${f}" == "$KUBECONFIG" ]]; then  # current kubeconfig
            f="* ${f}"
        else
            f="  ${f}"
        fi

        # print it
        echo "$f"
    done
}

# kcmgr show
# show content of current or specified kubeconfig
function _kcmgr_show() {
    kubeconfig="$(_kubeconfig_path "$1")"
    echo "# ${kubeconfig}"
    if [[ -f "$kubeconfig" ]]; then
        cat "$kubeconfig"
    fi
}

# kcmgr set
# set KUBECONFIG environment variable
function _kcmgr_set() {
    # no kubeconfig to set
    if [[ $# -lt 1 ]]; then
        _kcmgr_unset
        return
    fi

    export KUBECONFIG="$(_kubeconfig_path "$1")"
}

# kcmgr unset
# unset KUBECONFIG environment variable
function _kcmgr_unset() {
    unset KUBECONFIG
}

# kcmgr edit
# edit current or specified kubeconfig
function _kcmgr_edit() {
    kubeconfig="$(_kubeconfig_path "$1")"
    editor="$(_get_editor)" || return 1
    "$editor" "$kubeconfig"
}

# kcmgr delete
# delete current or specified kubeconfig
function _kcmgr_delete() {
    kubeconfig="$(_kubeconfig_path "$1")"

    # double chekc
    read ret"?Delete '${kubeconfig}'? (Y/n): "
    if [[ "$ret" == "Y" ]]; then
        rm "$kubeconfig"
        echo "deleted"
    else
        echo "abort"
    fi
}

# get editor
function _get_editor() {
    if [[ -f =vim ]]; then
        echo "vim"
    elif [[ -f =vi ]]; then
        echo "vi"
    else
        return 1
    fi
}

# get kubeconfig path from name
function _kubeconfig_path() {
    if [[ "$1" == "" ]]; then
        echo "${KUBECONFIG:-${HOME}/.kube/config}"
    elif [[ "${1:0:2}" == "./" || "${1:0:1}" == "/" || "${1:0:1}" == "~" ]]; then
        echo "$1"
    else
        echo "${_kubeconfigs_dir}/${1}"
    fi
}
