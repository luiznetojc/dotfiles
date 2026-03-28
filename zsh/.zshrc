# =========================
# POWERLEVEL10K INSTANT PROMPT
# =========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# =========================
# PATHS
# =========================
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"


# Mostrar PATH em linhas (útil para debug)
alias path='echo -e ${PATH//:/\\n}'


# =========================
# OH MY ZSH
# =========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"


plugins=(
  git
  zsh-interactive-cd
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  fzf
  fzf-tab
  web-search
  copypath
  copyfile
  dirhistory
  aliases
  alias-finder
  macos
  node
  npm
)


source $ZSH/oh-my-zsh.sh


# =========================
# COMPLETION CORE
# =========================
# menu interativo
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# =========================
# FZF CONFIG (Mac - Funciona 100%)
# =========================


# Carrega UMA VEZ só
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Define fzf-cd-widget (que faltava)
fzf-cd-widget() {
  local dir
  dir=$(find . -path '*/\\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m \
    --preview 'eza --tree --level=2 {} || ls -la {}' \
    --preview-window right:50%) &&
  cd "$dir" || return 1
}


# Registra como widget ZLE
zle -N fzf-cd-widget


# Bind: Ctrl+Option+C no Mac
bindkey '^[c' fzf-cd-widget  # ESC+C (mais confiável que Ctrl+Option)


export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --style=numbers --color=always {} 2>/dev/null | head -200 || head -200 {}"
'


export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window up:3:wrap'


# =========================
# FZF-TAB (COMPLETION BONITA)
# =========================
zstyle ':fzf-tab:*' switch-group ',' '.'


zstyle ':fzf-tab:complete:*' fzf-preview '
  if [ -d $realpath ]; then
    command -v eza >/dev/null && eza --tree --level=2 --icons $realpath || ls $realpath
  else
    command -v bat >/dev/null && bat --style=numbers --color=always $realpath 2>/dev/null | head -200 || head -200 $realpath
  fi
'


# navegação pelo fzf-tab no TAB
bindkey '^I' fzf-tab-complete


# =========================
# AUTOSUGGESTIONS / HISTORY (ATUIN) / THEFUCK
# =========================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666"


# Atuin: history avançado (busca por dir, regex, etc)
eval "$(atuin init zsh)"  # substitui history padrão pelo banco sqlite


# TheFuck: corrigir comandos errados com `fuck`
eval "$(thefuck --alias)"


# aceitar sugestão com seta →
bindkey '^[[C' autosuggest-accept


# seta ↑ busca histórico por prefixo (history-substring-search)
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search


# =========================
# ZOXIDE (CD INTELIGENTE) + FZF
# =========================
eval "$(zoxide init zsh)"


# z → vai para diretório frequente; zz → usar fzf
z() { __zoxide_z "$@"; }
zz() { __zoxide_zi "$@"; }  # abre prompt fzf com dirs ranqueados


# =========================
# HISTORY
# =========================
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history


setopt SHARE_HISTORY         # compartilha entre shells
setopt HIST_IGNORE_ALL_DUPS  # remove duplicados
setopt HIST_REDUCE_BLANKS    # remove espaços extras
setopt INC_APPEND_HISTORY    # salva imediatamente
setopt HIST_IGNORE_SPACE     # ignora comandos que começam com espaço


# =========================
# ALIASES BÁSICOS
# =========================
alias ls="eza --icons"
alias ll="eza -lh"
alias la="eza -a"
alias lla="eza -lah"
alias cat="bat"


alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."


alias reload="source ~/.zshrc"


# segurança leve
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'


# =========================
# FZF POWER ALIASES
# =========================
alias ff="fzf"
alias fkill="ps aux | fzf | awk '{print \\$2}' | xargs kill -9"
alias fcd="cd \$(find . -type d -maxdepth 5 2>/dev/null | fzf)"


# procurar arquivo e abrir no editor (nvim/code)
alias fedit='${EDITOR:-nvim} "$(fd . | fzf)"'


# =========================
# GIT HELPERS
# =========================
alias g='git'
alias gst='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'


# fuzzy checkout de branch
gcof() {
  local branch
  branch=$(git branch --all | sed "s/^[* ] //g" | fzf) || return
  git checkout "$(echo "$branch" | sed "s#remotes/[^/]*/##")"
}


# =========================
# DOCKER / KUBECTL HELPERS (SE USAR)
# =========================
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlogs='docker logs -f'
alias dstopall='docker stop $(docker ps -q)'


alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kga='kubectl get all'
alias kctx='kubectl config get-contexts'
alias kusethis='kubectl config use-context'


# =========================
# FUNCTIONS
# =========================
mkcd() {
  mkdir -p "$1" && cd "$1"
}


# abrir projeto pela raiz git
cproj() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not a git repo"; return 1; }
  cd "$root"
}


# busca recursiva com ripgrep + fzf
frg() {
  local file
  file=$(rg --files | fzf --preview 'bat --style=numbers --color=always {} | head -200') || return
  ${EDITOR:-nvim} "$file"
}


# =========================
# EXTRAS / COMPLETIONS EXTRAS
# =========================
fpath=($HOME/.zsh/completions $fpath)


# Angular CLI
command -v ng >/dev/null && source <(ng completion script)


# Google Cloud SDK
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && source "$HOME/google-cloud-sdk/completion.zsh.inc"


# =========================
# NVM
# =========================
export NVM_DIR="$HOME/.nvm"

# Lazy load do NVM para reduzir startup
lazy_load_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
nvm() { lazy_load_nvm; nvm "$@"; }
node() { lazy_load_nvm; node "$@"; }
npm() { lazy_load_nvm; npm "$@"; }
npx() { lazy_load_nvm; npx "$@"; }


# =========================
# EDITOR / LANG
# =========================
export EDITOR="nvim"
export VISUAL="nvim"
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8


# =========================
# POWERLEVEL10K CONFIG
# =========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
