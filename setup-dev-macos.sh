#!/usr/bin/env bash
#
# Provisiona um macOS novo com o ambiente de desenvolvimento completo.
# Idempotente: pode rodar mais de uma vez sem quebrar nada.
#
#   ./setup-dev-macos.sh

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- versões, num único lugar ---------------------------------------------
JAVA_PADRAO="17.0.13-zulu"
JAVA_EXTRA="21.0.9-zulu"
NODE_VERSAO="--lts"          # ou uma versão fixa, ex.: "22.11.0"
# ---------------------------------------------------------------------------

log "Command Line Tools"
xcode-select -p >/dev/null 2>&1 && ok "já instalado" || xcode-select --install 2>/dev/null

log "Homebrew"
if have brew; then
  ok "já instalado"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
  [ -x /usr/local/bin/brew ]    && eval "$(/usr/local/bin/brew shellenv)"      # Intel
fi
brew update

log "Pacotes essenciais"
brew install curl wget git unzip gnupg jq ca-certificates

log "Warp — terminal usado no dia a dia"
brew list --cask warp >/dev/null 2>&1 && ok "já instalado" || brew install --cask warp

log "Fonte com glifos powerline"
# Sem uma Nerd Font, os separadores da statusline viram quadrados.
brew install --cask font-meslo-lg-nerd-font 2>/dev/null || warn "instale manualmente uma Nerd Font"

log "SDKMAN e Java"
if [ ! -d "$HOME/.sdkman" ]; then curl -s "https://get.sdkman.io" | bash; fi
set +u; source "$HOME/.sdkman/bin/sdkman-init.sh"; set -u
sdk install java "$JAVA_PADRAO" </dev/null || true
sdk install java "$JAVA_EXTRA"  </dev/null || true
sdk default java "$JAVA_PADRAO" || true

log "Node via NVM"
brew install nvm
export NVM_DIR="$HOME/.nvm"; mkdir -p "$NVM_DIR"
set +u; source "$(brew --prefix nvm)/nvm.sh"; set -u
nvm install "$NODE_VERSAO"
npm install -g yarn

log "Docker, bancos e IDEs"
for c in docker dbeaver-community visual-studio-code intellij-idea-ce postman mongodb-compass; do
  brew list --cask "$c" >/dev/null 2>&1 && ok "$c já instalado" || brew install --cask "$c"
done

install_claude_code
configure_ccstatusline

log "Limpando caches"
brew cleanup

cat <<'EOF'

Pronto. Passos que dependem de você:

  1. No Warp: Settings → Appearance → Text → escolha "MesloLGS Nerd Font".
     Sem isso, os separadores da statusline aparecem como quadrados.

  2. Autentique o Claude Code:  claude
  3. Autentique o GitHub CLI:   gh auth login

  4. Restaure suas configurações pessoais a partir do backup:
     ./restore-claude.sh /caminho/do/backup-ambiente-AAAAMMDD

EOF
