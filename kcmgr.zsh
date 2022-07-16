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
    echo "  ls, list  list kubeconfig"
    echo "  set       set KUBECONFIG environment variable"
    echo "  unset     unset KUBECONFIG environment variable"
    echo "  help      print this message"
}

# kubeconfig manager
function kcmgr() {
    if [[ $# -lt 1 ]]; then
        _kcmgr_help
        return 1
    fi

    case $1 in
        (ls|list) _kcmgr_ls
        ;;
        (set) _kcmgr_set ${@:2}
        ;;
        (unset) _kcmgr_unset
        ;;
        (help) _kcmgr_help
        ;;
    esac
}

# kcmgr ls
# list kubeconfig
function _kcmgr_ls() {
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

# kcmgr set
# set KUBECONFIG environment variable
function _kcmgr_set() {
    # no kubeconfig to set
    if [[ $# -lt 1 ]]; then
        _kcmgr_unset
        return
    fi

    case ${1:0:1} in
    (.|/)
        # not in configs dir
        export KUBECONFIG="$1"
    ;;
    (*)
        # in configs dir
        export KUBECONFIG="${_kubeconfigs_dir}/${1}"
    ;;
    esac
}

# kcmgr unset
# unset KUBECONFIG environment variable
function _kcmgr_unset() {
    unset KUBECONFIG
}
