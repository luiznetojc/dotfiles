#!/usr/bin/env bash
# ==============================================================================
# app-install - Instalador automatizado para aplicativos no Linux (.tar, .zip, .AppImage)
# Configura automaticamente:
#   - Extração organizada em ~/.local/share/apps/
#   - Binário acessível direto no terminal em ~/.local/bin/
#   - Atalho integrado na pesquisa de aplicativos (~/.local/share/applications/)
#   - Atalho na Área de Trabalho com permissão de execução
# ==============================================================================

set -e

# Estilos de saída
GREEN=$'\e[1;32m'
BLUE=$'\e[1;34m'
YELLOW=$'\e[1;33m'
RED=$'\e[1;31m'
CYAN=$'\e[1;36m'
BOLD=$'\e[1m'
NC=$'\e[0m'

APPS_DIR="$HOME/.local/share/apps"
BIN_DIR="$HOME/.local/bin"
DESKTOP_APPS_DIR="$HOME/.local/share/applications"
USER_DESKTOP="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
TMP_DIR=""

cleanup() {
    if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

show_help() {
    cat <<EOF
${BOLD}app-install${NC} - Instalador rápido de pacotes standalone (.tar.gz, .zip, .AppImage, etc.)

${BOLD}Uso:${NC}
  app-install <arquivo|URL>         Instala um app a partir de arquivo local ou link
  app-install --list | -l           Lista aplicativos instalados
  app-install --remove | -r <nome>  Remove um aplicativo instalado
  app-install --help | -h           Mostra esta ajuda

${BOLD}Exemplos:${NC}
  app-install discord-0.0.94.tar.gz
  app-install postman-linux-x64.tar.gz
  app-install Obsidian-1.5.8.AppImage
  app-install https://example.com/app.tar.gz
  app-install --remove discord
EOF
}

list_apps() {
    echo -e "${BOLD}${BLUE}Aplicativos gerenciados em $APPS_DIR:${NC}"
    if [[ ! -d "$APPS_DIR" || -z "$(ls -A "$APPS_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Nenhum aplicativo encontrado em $APPS_DIR.${NC}"
        return
    fi

    for d in "$APPS_DIR"/*; do
        if [[ -d "$d" ]]; then
            local app
            app="$(basename "$d")"
            local bin_status="${RED}[sem binário]${NC}"
            local desk_status="${RED}[sem atalho]${NC}"

            if [[ -L "$BIN_DIR/$app" || -f "$BIN_DIR/$app" ]]; then
                bin_status="${GREEN}terminal: $app${NC}"
            fi

            if [[ -f "$DESKTOP_APPS_DIR/$app.desktop" ]]; then
                desk_status="${GREEN}pesquisa: ativo${NC}"
            fi

            echo -e "  • ${BOLD}$app${NC} ($bin_status | $desk_status)"
        fi
    done
}

remove_app() {
    local target="$1"
    if [[ -z "$target" ]]; then
        echo -e "${RED}Erro: informe o nome do aplicativo a ser removido.${NC}"
        list_apps
        exit 1
    fi

    local slug
    slug=$(echo "$target" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

    echo -e "${YELLOW}Removendo aplicativo: $target...${NC}"
    local found=0

    if [[ -d "$APPS_DIR/$slug" ]]; then
        rm -rf "$APPS_DIR/$slug"
        echo -e "  ${GREEN}✓${NC} Pasta de instalação removida ($APPS_DIR/$slug)"
        found=1
    fi

    if [[ -L "$BIN_DIR/$slug" || -f "$BIN_DIR/$slug" ]]; then
        rm -f "$BIN_DIR/$slug"
        echo -e "  ${GREEN}✓${NC} Comando no terminal removido ($BIN_DIR/$slug)"
        found=1
    fi

    if [[ -f "$DESKTOP_APPS_DIR/$slug.desktop" ]]; then
        rm -f "$DESKTOP_APPS_DIR/$slug.desktop"
        echo -e "  ${GREEN}✓${NC} Atalho do menu removido ($DESKTOP_APPS_DIR/$slug.desktop)"
        found=1
    fi

    if [[ -f "$USER_DESKTOP/$slug.desktop" ]]; then
        rm -f "$USER_DESKTOP/$slug.desktop"
        echo -e "  ${GREEN}✓${NC} Atalho da Área de Trabalho removido"
        found=1
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$DESKTOP_APPS_DIR" 2>/dev/null || true
    fi

    if [[ $found -eq 1 ]]; then
        echo -e "\n${GREEN}✓ Aplicativo '$target' removido com sucesso!${NC}"
    else
        echo -e "${RED}Nenhum rastro encontrado para '$target'.${NC}"
    fi
}

# Processamento de flags
case "$1" in
    -h|--help|"")
        if [[ -z "$1" ]]; then
            show_help
            exit 1
        fi
        show_help
        exit 0
        ;;
    -l|--list)
        list_apps
        exit 0
        ;;
    -r|--remove)
        shift
        remove_app "$1"
        exit 0
        ;;
esac

TARGET="$1"

# Se for URL, baixa primeiro
if [[ "$TARGET" =~ ^https?:// ]]; then
    echo -e "${CYAN}==> Baixando arquivo remoto:${NC} $TARGET"
    TMP_DOWNLOAD="$(mktemp -d)/$(basename "$TARGET" | cut -d? -f1)"
    mkdir -p "$(dirname "$TMP_DOWNLOAD")"
    curl -fL --progress-bar "$TARGET" -o "$TMP_DOWNLOAD"
    TARGET="$TMP_DOWNLOAD"
fi

if [[ ! -f "$TARGET" ]]; then
    echo -e "${RED}Erro: Arquivo '$TARGET' não encontrado.${NC}"
    exit 1
fi

mkdir -p "$APPS_DIR" "$BIN_DIR" "$DESKTOP_APPS_DIR"

FILENAME="$(basename "$TARGET")"
echo -e "${BOLD}${BLUE}==> Processando:${NC} $FILENAME"

# Preparar pasta temporária de extração
TMP_DIR="$(mktemp -d -t app-install-XXXXXX)"

IS_APPIMAGE=0
IS_STANDALONE_BIN=0

# Detecta formato e descompacta
if [[ "$FILENAME" =~ \.AppImage$ ]] || file "$TARGET" | grep -qi "AppImage"; then
    IS_APPIMAGE=1
    cp "$TARGET" "$TMP_DIR/$FILENAME"
    chmod +x "$TMP_DIR/$FILENAME"
elif [[ "$FILENAME" =~ \.(tar\.gz|tgz)$ ]]; then
    tar -xzf "$TARGET" -C "$TMP_DIR"
elif [[ "$FILENAME" =~ \.(tar\.xz|txz)$ ]]; then
    tar -xJf "$TARGET" -C "$TMP_DIR"
elif [[ "$FILENAME" =~ \.(tar\.bz2|tbz2)$ ]]; then
    tar -xjf "$TARGET" -C "$TMP_DIR"
elif [[ "$FILENAME" =~ \.tar$ ]]; then
    tar -xf "$TARGET" -C "$TMP_DIR"
elif [[ "$FILENAME" =~ \.zip$ ]]; then
    unzip -q "$TARGET" -d "$TMP_DIR"
elif file "$TARGET" | grep -qi "ELF .* executable"; then
    IS_STANDALONE_BIN=1
    cp "$TARGET" "$TMP_DIR/$FILENAME"
    chmod +x "$TMP_DIR/$FILENAME"
else
    # Tenta tar genérico se falhar
    if ! tar -xf "$TARGET" -C "$TMP_DIR" 2>/dev/null; then
        echo -e "${RED}Formato não suportado ou arquivo corrompido.${NC}"
        exit 1
    fi
fi

# Se houver apenas uma pasta raiz dentro do zip/tar, descemos para ela
WORK_DIR="$TMP_DIR"
ITEMS_IN_TMP=("$TMP_DIR"/*)
if [[ ${#ITEMS_IN_TMP[@]} -eq 1 && -d "${ITEMS_IN_TMP[0]}" ]]; then
    WORK_DIR="${ITEMS_IN_TMP[0]}"
fi

# Sugestão de nome do App baseado no nome do arquivo
DEFAULT_NAME=$(echo "$FILENAME" | sed -E 's/\.(tar\.(gz|xz|bz2)|tgz|txz|zip|AppImage)$//i' | sed -E 's/[-_](x86_64|amd64|linux|x64|arm64|aarch64).*//i' | sed -E 's/[-_][0-9]+(\.[0-9]+)*.*//')
# Primeira letra maiúscula
DEFAULT_NAME="$(echo "${DEFAULT_NAME:0:1}" | tr '[:lower:]' '[:upper:]')${DEFAULT_NAME:1}"

echo ""
echo -e "${CYAN}Configuração do Aplicativo:${NC}"
read -rp "  Nome para exibição [$DEFAULT_NAME]: " APP_NAME_INPUT
APP_NAME="${APP_NAME_INPUT:-$DEFAULT_NAME}"

CMD_SLUG=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
read -rp "  Nome do comando no terminal [$CMD_SLUG]: " CMD_INPUT
CMD_NAME="${CMD_INPUT:-$CMD_SLUG}"

# Encontrar executável
SELECTED_EXEC=""
if [[ $IS_APPIMAGE -eq 1 ]]; then
    SELECTED_EXEC="$FILENAME"
elif [[ $IS_STANDALONE_BIN -eq 1 ]]; then
    SELECTED_EXEC="$FILENAME"
else
    # Busca arquivos executáveis ou binários ELF, ignorando libs e helpers comuns
    mapfile -t EXEC_CANDIDATES < <(find "$WORK_DIR" -type f \( -perm -u+x -o -name "*.sh" \) 2>/dev/null \
        | grep -vE '(\.so(\.[0-9]+)*$|\.node$|chrome-sandbox$|crashpad_handler$|/lib/|/\.git/)' \
        | sed "s|^$WORK_DIR/||")

    if [[ ${#EXEC_CANDIDATES[@]} -eq 0 ]]; then
        # Se não achou nenhum com +x, busca qualquer arquivo regular executável ELF
        mapfile -t EXEC_CANDIDATES < <(find "$WORK_DIR" -maxdepth 2 -type f 2>/dev/null | while read -r f; do
            if file "$f" | grep -qi "executable"; then
                echo "${f#$WORK_DIR/}"
            fi
        done)
    fi

    if [[ ${#EXEC_CANDIDATES[@]} -eq 1 ]]; then
        SELECTED_EXEC="${EXEC_CANDIDATES[0]}"
        echo -e "  Executável detectado: ${GREEN}$SELECTED_EXEC${NC}"
    elif [[ ${#EXEC_CANDIDATES[@]} -gt 1 ]]; then
        echo -e "\n  ${YELLOW}Múltiplos executáveis encontrados. Escolha o principal:${NC}"
        if command -v fzf &>/dev/null && [[ -t 0 ]]; then
            SELECTED_EXEC=$(printf "%s\n" "${EXEC_CANDIDATES[@]}" | fzf --prompt="  Selecione o binário > " --height=40% --reverse)
        else
            for i in "${!EXEC_CANDIDATES[@]}"; do
                echo "    $((i+1))) ${EXEC_CANDIDATES[$i]}"
            done
            read -rp "  Digite o número correspondente [1]: " CHOICE
            CHOICE="${CHOICE:-1}"
            SELECTED_EXEC="${EXEC_CANDIDATES[$((CHOICE-1))]}"
        fi
    fi

    if [[ -z "$SELECTED_EXEC" ]]; then
        read -rp "  Caminho relativo do executável: " SELECTED_EXEC
    fi
fi

# Encontrar ícone
SELECTED_ICON=""
mapfile -t ICON_CANDIDATES < <(find "$WORK_DIR" -type f \( -name "*.png" -o -name "*.svg" \) 2>/dev/null \
    | grep -vE '(\.git/|node_modules/)' \
    | sort -r \
    | sed "s|^$WORK_DIR/||")

if [[ ${#ICON_CANDIDATES[@]} -gt 0 ]]; then
    # Prioriza arquivos com "icon" ou "logo" no nome
    for ic in "${ICON_CANDIDATES[@]}"; do
        if [[ "$ic" =~ (icon|logo) ]]; then
            SELECTED_ICON="$ic"
            break
        fi
    done
    [[ -z "$SELECTED_ICON" ]] && SELECTED_ICON="${ICON_CANDIDATES[0]}"
    echo -e "  Ícone detectado: ${GREEN}$SELECTED_ICON${NC}"
fi

echo ""
echo -e "${BLUE}==> Instalando...${NC}"

TARGET_APP_DIR="$APPS_DIR/$CMD_NAME"
if [[ -d "$TARGET_APP_DIR" ]]; then
    echo -e "  ${YELLOW}Pasta $TARGET_APP_DIR já existe. Atualizando...${NC}"
    rm -rf "$TARGET_APP_DIR"
fi

mkdir -p "$TARGET_APP_DIR"
cp -a "$WORK_DIR"/* "$TARGET_APP_DIR/" 2>/dev/null || cp -a "$WORK_DIR"/.[!.]* "$TARGET_APP_DIR/" 2>/dev/null || true

FINAL_EXEC="$TARGET_APP_DIR/$SELECTED_EXEC"
chmod +x "$FINAL_EXEC"

# Link simbólico para o terminal
ln -sf "$FINAL_EXEC" "$BIN_DIR/$CMD_NAME"
echo -e "  ${GREEN}✓${NC} Comando terminal criado: $BIN_DIR/$CMD_NAME"

# Resolver caminho absoluto do ícone
FINAL_ICON="application-x-executable"
if [[ -n "$SELECTED_ICON" && -f "$TARGET_APP_DIR/$SELECTED_ICON" ]]; then
    FINAL_ICON="$TARGET_APP_DIR/$SELECTED_ICON"
fi

# Criação do arquivo .desktop
DESKTOP_FILE="$DESKTOP_APPS_DIR/$CMD_NAME.desktop"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Instalado via app-install
Exec=$FINAL_EXEC %U
Icon=$FINAL_ICON
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_FILE"
echo -e "  ${GREEN}✓${NC} Atalho na pesquisa de apps: $DESKTOP_FILE"

# Copiar para a Área de Trabalho se ela existir
if [[ -d "$USER_DESKTOP" ]]; then
    cp "$DESKTOP_FILE" "$USER_DESKTOP/"
    if command -v gio &>/dev/null; then
        gio set "$USER_DESKTOP/$CMD_NAME.desktop" metadata::trusted true 2>/dev/null || true
    fi
    echo -e "  ${GREEN}✓${NC} Atalho criado na Área de Trabalho ($USER_DESKTOP)"
fi

# Atualizar base de dados de atalhos
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$DESKTOP_APPS_DIR" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}${BOLD}Tudo pronto! ${APP_NAME} instalado com sucesso.${NC}"
echo -e "  • Para abrir via terminal:   ${CYAN}$CMD_NAME${NC}"
echo -e "  • Para buscar no sistema:    Procure por '${BOLD}$APP_NAME${NC}' no menu de apps"
echo -e "  • Para desinstalar no futuro: ${YELLOW}app-install --remove $CMD_NAME${NC}"
