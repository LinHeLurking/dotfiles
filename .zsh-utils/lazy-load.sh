# helpers
if ! typeset -f plugin_bootstrap > /dev/null ; then 
    HELPER_DIR=${HELPER_DIR:-$HOME}
    source "$HELPER_DIR/.zsh-utils/plugin-bootstrap.sh"
    unset HELPER_DIR
fi 

function __lazyload_command() {
    # return if no arg
    [[ "$1" == "" ]] && return
    # lazyload command
    # multiple commands can be loaded at once and cancel those aliases.
    local _cancel_command=""
    for cmd in $@; do
        local _cancel_command="$_cancel_command; unfunction $cmd"
    done
    for name in $@; do
        # command alias 
        eval "$name() { \
            $_cancel_command; \
            __load_${name}_command; \
            $cmd "\$@" \
        }"
    done 
}

function __lazyload_completion() {
    # return if no arg
    [[ "$1" == "" ]] && return
    # lazyload completion
    local _cancel_command=""
    for cmd in $@; do
        local _cancel_command="$_cancel_command; unfunction $cmd"
    done
    for name in $@; do 
        local load_command_flag="__$(echo $name | tr '[:lower:]' '[:upper:]')_COMMAND_LOADED"
        eval "_$name() { \
            if [[ \"\${${load_command_flag}}\" == \"0\" ]]; then \
                $_cancel_command; \
                __load_${name}_command; \
            fi; \
            compdef -d $name; \
            unfunction _$name; \
            __load_${name}_completion; \
            if typeset -f _$name > /dev/null; then \
                _$name "\$@"; \
            fi; \
        }"
        compdef _$name $name
    done 
}

#
# lazy load conda
# 

# load indicator
if [[ -n "$(command -v conda)" ]]; then 
    export __CONDA_COMMAND_LOADED=0
    export __CONDA_COMPLETION_LOADED=0
    # loader
    local conda_bin=$(command -v conda)
    function __load_conda_command() {
        if [[ "$__CONDA_COMMAND_LOADED" == "1" ]]; then
            return
        fi
        # conda init
        if [[ -z "$conda_bin" ]]; then 
            printf "No conda binary found! Consider add it to \$PATH first!\n"
            return 
        fi
        if [[ -L "$conda_bin" ]];then 
            conda_bin=$(readlink -f ${conda_bin})
        fi 
        conda_setup="$('${conda_bin}' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$conda_setup"
        else
            local conda_base=$(dirname $(dirname ${conda_bin}))
            if [ -f "${conda_base}/etc/profile.d/conda.sh" ]; then
                . "${conda_base}/etc/profile.d/conda.sh"
            else
                export PATH="${conda_base}/bin:$PATH"
            fi
        fi
        unset conda_setup
        export __CONDA_COMMAND_LOADED=1
    }
    function __load_conda_completion() {
        if [[ "$__COMDA_COMPLETION_LOADED" == "1" ]]; then 
            return
        fi 
        # load conda-zsh completion
        plugin_bootstrap conda-zsh-completion
        omz plugin load conda-zsh-completion
        export __CONDA_COMPLETION_LOADED=1
    }
    __lazyload_command conda
    __lazyload_completion conda
fi

#
# lazy load nvm 
#
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
    export __NVM_COMMAND_LOADED=0
    export __NVM_COMPLETION_LOADED=0
    function __load_nvm_command() {
        if [[ "$__NVM_COMMAND_LOADED" == "1" ]]; then 
            return 
        fi 
        if [[ -n "$HOMEBREW_PREFIX" ]]; then 
            local nvm_sh="$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
        else
            local nvm_sh="$NVM_DIR/nvm.sh"
        fi 
        [ -s "$nvm_sh" ] && source "$nvm_sh"
    }
    function __load_nvm_completion() {
        if [[ "$__NVM_COMPLETION_LOADED" == "1" ]]; then 
            return
        fi 
        if [[ -n "$HOMEBREW_PREFIX" ]]; then 
            local nvm_comp="$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
        else
            local nvm_comp="$NVM_DIR/bash_completion"
        fi 
        [ -s "$nvm_comp" ] && source "$nvm_comp"
    }
    __lazyload_command nvm 
    __lazyload_completion nvm
fi

#
# lazy load pipx
#
if [[ -n "$(command -v pipx)" ]]; then
    export __PIPX_COMMAND_LOADED=1 # we have already added pipx binary to $PATH 
    export __PIPX_COMPLETION_LOADED=0
    function __load_pipx_completion() {
        if [[ "$__PIPX_COMPLETION_LOADED" == "1" ]]; then 
            return 
        fi 
        # pipx autocompletion 
        eval "$(register-python-argcomplete pipx)"
    }
    __lazyload_completion pipx
fi
