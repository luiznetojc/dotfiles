#!/usr/bin/env bash
set -e

echo "[*] Iniciando bootstrap..."

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# -------------------------
# 1. Homebrew
# -------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "[*] Homebrew já instalado, rodando brew update..."
  brew update
fi

# -------------------------
# 2. Pacotes essenciais
# -------------------------
echo "[*] Instalando pacotes via Homebrew..."
brew install \
  zsh \
  git \
  eza \
  bat \
  fzf \
  zoxide \
  atuin \
  thefuck \
  fd \
  ripgrep \
  nvm \
  node \
  neovim \
  coreutils

# fzf keybindings + completion
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

# -------------------------
# 3. Oh My Zsh + plugins
# -------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[*] Instalando Oh My Zsh (unattended)..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "[*] Oh My Zsh já instalado."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "[*] Instalando tema powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# plugins: zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab, zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# -------------------------
# 4. Symlink do .zshrc / .p10k.zsh
# -------------------------
echo "[*] Criando symlinks de dotfiles..."

backup_file() {
  local file="$1"
  if [ -f "$file" ] && [ ! -L "$file" ]; then
    local ts
    ts=$(date +%Y%m%d%H%M%S)
    echo "  - Backup de $file -> ${file}_${ts}"
    mv "$file" "${file}_${ts}"
  fi
}

backup_file "$HOME/.zshrc"
backup_file "$HOME/.p10k.zsh"

ln -fs "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -fs "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

mkdir -p "$HOME/.config"
ln -fs "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "[*] Symlinks criados."

# -------------------------
# 5. Zsh como shell padrão
# -------------------------
if ! grep -q "$(command -v zsh)" /etc/shells; then
  echo "[*] Adicionando zsh do Homebrew em /etc/shells (precisa de sudo)..."
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "[*] Alterando shell padrão para zsh..."
  chsh -s "$(command -v zsh)"
fi

echo "[*] Bootstrap concluído. Abra um novo terminal ou rode: exec zsh"
