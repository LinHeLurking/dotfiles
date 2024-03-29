# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Lazy NVM breaks so many neovim lsp installer :(
# export NVM_LAZY=1
# NVM_LAZY_COMMAND=npx
# conda-zsh-completion is difficult to be lazily loaded :(
plugins=(git zsh-autosuggestions zsh-syntax-highlighting conda-zsh-completion rust)

source $ZSH/oh-my-zsh.sh

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ls="ls --color=auto"
# Alias VIM to NeoVIM
alias nvim="~/.local/bin/nvim.appimage"
alias vim="nvim"
alias vvim="/usr/bin/vim"

. ~/.proxy.sh
# set_proxy
export GPG_TTY=$TTY

_verify_plugin() {
    local base_dir="$1"
    local name="$2"
    test -f "${base_dir}/plugins/${name}/${name}.plugin.zsh" || \
        test -f "${base_dir}/plugin/${name}/_${name}"
}

_lazyload_plugin() {
    local plugin_name="$1"
    if _verify_plugin $ZSH_CUSTOM $plugin; then 
        local plugin=$ZSH_CUSTOM/plugins/$plugin_name
        . $plugin
    elif _verify_plugin $ZSH $plugin; then
        local plugin=$ZSH/plugins/$plugin_name
        . $plugin
    fi
}

lazyload_cmd() {
    # return if no arg 
    [[ "$1" == "" ]] && return
    # lazyload command
    eval "function $1() { \
        unfunction $1; \
        _lazyload_command__$1; \
        $1 \$@ \
    }"
}

lazyload_completion() {
    # return if no arg 
    [[ "$1" == "" ]] && return
    # lazyload completion
    local comp_name="_tmp_completion__$1"
    eval "${comp_name}() { \
        compdef -d $1; \
        unfunction ${comp_name}; \
        _lazyload_completion__$1; \
    }"
    compdef $comp_name $1
}

export NVM_DIR="$HOME/.nvm"
_lazyload_command__nvm() {
    # local NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

_lazyload_completion__nvm() {
    # local NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    _lazyload_plugin nvm
}

_lazyload_command__npm() {
    nvm help 2>&1 > /dev/null
}

_lazyload_command__node() {
    nvm help 2>&1 > /dev/null
}

_lazyload_command__conda() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/linhe/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/linhe/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/home/linhe/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/linhe/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
}

#compdef nala
_nala_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" _NALA_COMPLETE=complete_zsh nala)
}

_lazyload_completion__nala() {
    #compdef nala
    compdef _nala_completion nala
}

_lazyload_command__cargo() {
    # Rust
    source ~/.cargo/env
}

_lazyload_command__rustup() {
    source ~/.cargo/env
}

_load_command__build() {
    local build_cmd="$HOME/.smart_build.sh"
    [[ ! -f "$build_cmd" ]] && echo "$build_cmd not found!" && return 2
    . "$build_cmd"
}

_load_command__install() {
    local install_cmd="$HOME/.smart_install.sh"
    [[ ! -f "$install_cmd" ]] && echo "$install_cmd not found!" && return 2
    . "$install_cmd"
}

# directly load nvm to enable npm/node executable for neovim usage :(
_lazyload_command__nvm
# lazyload_cmd nvm
lazyload_completion nvm
lazyload_cmd conda
lazyload_completion nala
lazyload_cmd cargo
unsetopt autocd
_load_command__build
_load_command__install


# host dependent cuda setup 
export PATH=/usr/local/cuda-12.2/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
