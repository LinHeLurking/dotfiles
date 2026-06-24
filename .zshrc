### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

### End of Zinit's installer chunk


### Begin of Zinit user settings

# Turbo mode
setopt promptsubst
PS1="READY >" # provide a simple prompt till the theme loads

# misc settings
setopt AUTO_PUSHD
unsetopt autocd

# history settings 
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
HISTFILE=${HOME}/.zsh_history

# Plugins
LOCAL_PLUGIN_DIR=~/.zplugins
if [[ ! -d $LOCAL_PLUGIN_DIR ]]; then
    mkdir -p $LOCAL_PLUGIN_DIR
fi

# Setup powerlevel10k theme.
zinit ice depth=1; zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode

zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

zinit wait lucid for \
	OMZL::git.zsh \
	OMZL::clipboard.zsh \
	OMZL::directories.zsh \
	OMZL::grep.zsh \
	OMZL::history.zsh \
	OMZL::spectrum.zsh \
	OMZP::git \
	OMZP::docker-compose \
	OMZP::uv \
	OMZP::z \
    OMZP::kubectl \
    OMZP::direnv

if [[ -f $LOCAL_PLUGIN_DIR/conda.zsh ]]; then 
    zinit ice wait lucid
    zinit snippet $LOCAL_PLUGIN_DIR/conda.zsh
    zinit ice wait lucid as"completion"
    zinit snippet https://github.com/conda-incubator/conda-zsh-completion/blob/main/_conda
fi

# export NVM_COMPLETION=true
# export NVM_SYMLINK_CURRENT="true"
# zinit wait lucid light-mode for lukechilds/zsh-nvm

zstyle ':completion:*:-command-:*' tag-order '!parameters'

### End of Zinit user settings

. "$HOME/.cargo/env"

alias vim=nvim

export EDITOR=$(which nvim)
export VISUAL=$EDITOR

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

start_agent

# alias docker=podman

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

# if you need git town
# source <(git town completions zsh)
