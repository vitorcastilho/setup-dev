#!/usr/bin/env bash
#
# Provisiona um Linux novo com o ambiente de desenvolvimento.
#
# Testado em Ubuntu; funciona em qualquer distribuição baseada em Debian,
# já que usa apt-get. Idempotente: pode rodar mais de uma vez sem quebrar nada.
#
#   ./setup-dev-linux.sh

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# --- versões, num único lugar ---------------------------------------------
JAVA_PADRAO="17.0.13-zulu"
JAVA_EXTRA="21.0.9-zulu"
NODE_VERSAO="--lts"          # ou uma versão fixa, ex.: "22.11.0"
# ---------------------------------------------------------------------------

log "Atualizando índices do apt"
sudo apt-get update -qq

log "Pacotes essenciais"
sudo apt-get install -y curl wget git unzip zip gnupg jq ca-certificates \
  build-essential apt-transport-https software-properties-common fontconfig

log "Warp — terminal usado no dia a dia"
if have warp-terminal; then
  ok "já instalado"
else
  sudo mkdir -p /usr/share/keyrings
  wget -qO- https://releases.warp.dev/linux/keys/warp.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/warpdotdev.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
    | sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y warp-terminal
fi

log "Fonte com glifos powerline"
# Sem uma Nerd Font, os separadores da statusline viram quadrados.
FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/MesloLGS* >/dev/null 2>&1; then
  ok "Meslo Nerd Font já instalada"
else
  mkdir -p "$FONT_DIR" && cd "$FONT_DIR"
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  unzip -oq Meslo.zip && rm -f Meslo.zip && fc-cache -f >/dev/null
  ok "Meslo Nerd Font instalada"
fi

log "SDKMAN e Java"
if [ ! -d "$HOME/.sdkman" ]; then curl -s "https://get.sdkman.io" | bash; fi
set +u; source "$HOME/.sdkman/bin/sdkman-init.sh"; set -u
sdk install java "$JAVA_PADRAO" </dev/null || true
sdk install java "$JAVA_EXTRA"  </dev/null || true
sdk default java "$JAVA_PADRAO" || true

log "Node via NVM"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
set +u; source "$NVM_DIR/nvm.sh"; set -u
nvm install "$NODE_VERSAO"
npm install -g yarn

log "Docker Engine"
if have docker; then
  ok "já instalado"
else
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  warn "faça logout e login para usar o docker sem sudo"
fi

log "GitHub CLI"
if have gh; then
  ok "já instalado"
else
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y gh
fi

install_claude_code
configure_ccstatusline

cat <<'EOF'

Pronto. Passos que dependem de você:

  1. No Warp: Settings → Appearance → Text → escolha "MesloLGS Nerd Font".
     Sem isso, os separadores da statusline aparecem como quadrados.

  2. Autentique o Claude Code:  claude
  3. Autentique o GitHub CLI:   gh auth login

  4. Restaure suas configurações pessoais a partir do backup:
     ./restore-claude.sh /caminho/do/backup-ambiente-AAAAMMDD

EOF
