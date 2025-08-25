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

# Setup powerlevel10k theme.
zinit wait"!" lucid nocd \
    atload="_p9k_precmd" for \
    romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

HISTSIZE=1000
SAVEHIST=50000
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/.zsh_history

zinit wait lucid for \
	OMZL::git.zsh \
	OMZL::clipboard.zsh \
	OMZL::directories.zsh \
	OMZL::grep.zsh \
	OMZL::history.zsh \
	OMZL::spectrum.zsh \
	OMZL::completion.zsh \
	OMZP::git \
	OMZP::docker-compose

if [[ -f ~/.zconda ]]; then 
    zinit ice wait lucid
    zinit snippet ~/.zconda
fi
zinit ice wait lucid as"completion"
zinit snippet https://github.com/conda-incubator/conda-zsh-completion/blob/main/_conda

export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"
zinit wait lucid light-mode for lukechilds/zsh-nvm

zinit ice wait lucid
zinit load zsh-users/zsh-syntax-highlighting.git

zinit ice wait lucid
zinit load zsh-users/zsh-autosuggestions.git

# Load this LAST!!!
zi for \
    atload"zicompinit; zicdreplay" \
    blockf \
    lucid \
    wait \
  zsh-users/zsh-completions

### End of Zinit user settings
