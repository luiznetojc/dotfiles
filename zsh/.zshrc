# =========================
# PATHS
# =========================
export PATH="$HOME/.local/bin:$HOME/.codeium/windsurf/bin:$HOME/.dotnet/tools:$PATH"

alias path='echo -e ${PATH//:/\\n}'

# =========================
# OH MY ZSH
# =========================
export ZSH="$HOME/.oh-my-zsh"
# Desativado porque o Starship cuida do prompt (evita sobreposição/lentidão)
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-completions
  fzf-tab
  web-search
  copypath
  copyfile
  dirhistory
  aliases
  alias-finder
  node
  npm
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
# =========================
# PLUGINS (ARCH WAY)
# =========================

# =========================
# COMPLETION CORE
# =========================
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'Nenhuma correspondência: %d'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# =========================
# FZF (ARCH)
# =========================
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

fzf-cd-widget() {
  local dir
  dir=$(fd -t d . | fzf --preview 'eza --tree --level=2 {} || ls -la {}') && cd "$dir"
}
zle -N fzf-cd-widget
bindkey '^[c' fzf-cd-widget

export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview-window=right:50%:wrap
'
export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window up:3:wrap'

# =========================
# FZF-TAB (PREVIEWS LATERAIS)
# =========================
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-min-height 28
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' fzf-flags --preview-window=right:60%:wrap --bind=ctrl-d:preview-page-down,ctrl-u:preview-page-up

# 1. Preview de comandos em geral (o que cada comando/script/alias/função faz)
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
  cmd="$word"
  if alias "$cmd" >/dev/null 2>&1; then
    echo -e "\033[1;36m=== ALIAS ===\033[0m"
    alias "$cmd"
  elif (( $+functions[$cmd] )); then
    echo -e "\033[1;36m=== FUNÇÃO SHELL ===\033[0m"
    functions "$cmd" | head -n 35
  elif tldr -L en --color always "$cmd" 2>/dev/null; then
    :
  elif whatis "$cmd" >/dev/null 2>&1; then
    echo -e "\033[1;36m=== MANUAL ===\033[0m"
    whatis "$cmd" 2>/dev/null
    echo ""
    man "$cmd" 2>/dev/null | col -b | head -n 35
  elif "$cmd" --help >/dev/null 2>&1; then
    echo -e "\033[1;36m=== AJUDA (--help) ===\033[0m"
    "$cmd" --help 2>&1 | head -n 35
  else
    echo -e "\033[1;33mComando:\033[0m $cmd"
    type -a "$cmd" 2>/dev/null
  fi
'

# 2. Preview de arquivos, diretórios e descrições de opções
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -n "$realpath" && -d "$realpath" ]]; then
    eza --tree --level=2 --icons "$realpath" 2>/dev/null || ls -la "$realpath"
  elif [[ -n "$realpath" && -f "$realpath" ]]; then
    bat --style=numbers --color=always "$realpath" 2>/dev/null | head -200
  elif [[ -n "$desc" ]]; then
    echo -e "\033[1;34m=== DESCRIÇÃO ===\033[0m\n$desc"
  fi
'

# 3. Previews úteis para comandos específicos
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status "$word" 2>/dev/null'
zstyle ':fzf-tab:complete:git-(checkout|switch):*' fzf-preview 'git log --color=always -n 5 "$word" 2>/dev/null'
zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|-export-):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:(kill|pkill):*' fzf-preview '[[ $group == "[process ID]" ]] && ps -p "$word" -o pid,user,%cpu,%mem,start,command 2>/dev/null'

# =========================
# AUTOSUGGEST / HISTORY
# =========================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666"

command -v atuin >/dev/null && eval "$(atuin init zsh)"
command -v thefuck >/dev/null && eval "$(thefuck --alias)"

bindkey '^[[C' autosuggest-accept

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# =========================
# ZOXIDE
# =========================
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

z() { __zoxide_z "$@"; }
zz() { __zoxide_zi "$@"; }

# =========================
# HISTORY
# =========================
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_SPACE

# =========================
# ALIASES
# =========================
command -v eza >/dev/null && alias ls="eza --icons"
alias ll="eza -lh"
alias la="eza -a"
alias lla="eza -lah"

command -v bat >/dev/null && alias cat="bat"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias reload="source ~/.zshrc"

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# Instalador de apps standalone (.tar.gz, .zip, .AppImage)
alias inst="app-install"
alias instalar="app-install"

# tldr em inglês
alias tldr="tldr -L en"

# =========================
# FZF POWER
# =========================
alias ff="fzf"
alias fkill="ps aux | fzf | awk '{print \$2}' | xargs kill -9"
alias fcd="cd \$(fd -t d . | fzf)"
alias fedit='${EDITOR:-nvim} "$(fd . | fzf)"'

# =========================
# GIT
# =========================
alias g='git'
alias gst='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

alias copy='wl-copy'
alias paste='wl-paste'
gcof() {
  local branch
  branch=$(git branch --all | sed "s/^[* ] //g" | fzf) || return
  git checkout "$(echo "$branch" | sed "s#remotes/[^/]*/##")"
}

# =========================
# FUNCTIONS
# =========================
mkcd() {
  mkdir -p "$1" && cd "$1"
}

cproj() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  cd "$root"
}

frg() {
  local file
  file=$(rg --files | fzf --preview 'bat --color=always {} | head -200') || return
  ${EDITOR:-nvim} "$file"
}

# =========================
# NVM (lazy load se existir)
# =========================
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  lazy_load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  }
  nvm() { lazy_load_nvm; nvm "$@"; }
  node() { lazy_load_nvm; node "$@"; }
  npm() { lazy_load_nvm; npm "$@"; }
  npx() { lazy_load_nvm; npx "$@"; }
fi

# =========================
# EDITOR / LANG
# =========================
export EDITOR="nvim"
export VISUAL="nvim"
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

if [ -e /home/luiz/.nix-profile/etc/profile.d/nix.sh ]; then
  . /home/luiz/.nix-profile/etc/profile.d/nix.sh
fi

# =========================
# GITHUB TOKEN (via gh CLI)
# =========================
if command -v gh >/dev/null 2>&1; then
  export WTF_GITHUB_TOKEN="${WTF_GITHUB_TOKEN:-$(gh auth token 2>/dev/null)}"
  export GITHUB_TOKEN="${GITHUB_TOKEN:-$WTF_GITHUB_TOKEN}"
fi

# =========================
# PROMPT & GREETING
# =========================
eval "$(starship init zsh)"

# Executa wtfutil na abertura do terminal interativo (se for um TTY real)
if [[ -t 0 ]] && [[ -t 1 ]] && [[ -o interactive ]] && [[ -n "$TERM" ]] && [[ "$TERM" != "dumb" ]] && [[ -z "$WTF_RAN" ]]; then
  export WTF_RAN=1
  if command -v wtfutil >/dev/null; then
    wtfutil
    clear
  fi
fi

# Executa fastfetch na abertura de terminais interativos
if [[ -o interactive ]] && command -v fastfetch >/dev/null; then
  fastfetch
fi