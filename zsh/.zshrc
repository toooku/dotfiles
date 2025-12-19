# shellcheck disable=SC2148
############################
# Basic zsh options
############################
setopt no_beep
setopt auto_cd
setopt correct
setopt interactive_comments

############################
# History
############################
HISTFILE=$HOME/.zsh_history
HISTSIZE=200000
SAVEHIST=200000

setopt append_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_find_no_dups
setopt extended_history

############################
# Completion (fast)
############################
autoload -Uz compinit
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZSH_COMPDUMP:h}"
compinit -C -d "$ZSH_COMPDUMP"

############################
# Zinit bootstrap
############################
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}Installing Zinit…%f"
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit \
      "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

############################
# Zinit annexes (required)
############################
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

############################
# Theme (pure)
############################
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

############################
# Plugins
############################

# completions
zinit light zsh-users/zsh-completions

# autosuggestions (lazy)
zinit ice wait"0" lucid
zinit light zsh-users/zsh-autosuggestions

# syntax highlighting (MUST be last)
zinit ice wait"0" lucid
zinit light zsh-users/zsh-syntax-highlighting

############################
# Tools
############################

# mise (single activation)
eval "$(mise activate zsh)"

# zoxide (smart cd)
zinit ice wait"1" lucid
zinit light ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# fzf (history / search boost)
zinit ice wait"1" lucid
zinit light junegunn/fzf

############################
# Key bindings
############################
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

############################
# Aliases (eza recommended)
############################
alias ls='eza --group-directories-first --icons'
alias ll='eza -lah --group-directories-first --icons'
alias la='eza -a --group-directories-first --icons'

############################
# LS_COLORS (oxocarbon light)
############################
export LS_COLORS="\
di=38;5;22:\
ex=38;5;24:\
ln=38;5;31:\
fi=0:\
pi=38;5;94:\
so=38;5;94:\
bd=38;5;94:\
cd=38;5;94:\
or=38;5;160:\
mi=38;5;160\
"

############################
# Terminal integration
############################
[[ "$TERM_PROGRAM" == "kiro" ]] && \
  . "$(kiro --locate-shell-integration-path zsh)"

# local (machine-specific)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
