declare -A __PLUGIN_NAME_MAP=(
    ["conda-zsh-completion"]="https://github.com/conda-incubator/conda-zsh-completion.git"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode.git"
)
function plugin_bootstrap() {
    if [[ "$1" == "" ]]; then 
        return 
    fi 
    for name in $@; do 
        if [[ -d "$ZSH/plugins/$name" ]]; then 
            continue
        fi 
        if [[ -d "$ZSH_CUSTOM" ]]; then 
            if [[ -n "$__UPDATE_PLUGINS" ]]; then 
                set -x 
                pushd $ZSH_CUSTOM/plugins/$name 
                git pull
                popd 
                set +x 
            fi 
            continue
        fi
        local addr="${__PLUGIN_NAME_MAP[$name]}"
        if [[ "$addr" == "" ]]; then 
            printf "Don't know where to clone $name \n"
            return
        fi 
        printf "Loading $name first...\n"
        set -x
        git clone $addr $ZSH_CUSTOM/plugins/$name
        set +x
        omz plugin load $name
    done 
}
