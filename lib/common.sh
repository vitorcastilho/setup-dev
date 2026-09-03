#!/usr/bin/env bash
# Funções compartilhadas entre os scripts de macOS e Linux.

set -uo pipefail

log()  { printf '\n\033[1;34m▸ %s\033[0m\n' "$*"; }
ok()   { printf '  \033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[0;33m!\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Instala o Claude Code (CLI oficial) se ainda não existir.
install_claude_code() {
  if have claude; then
    ok "Claude Code já instalado ($(claude --version 2>/dev/null | head -1))"
    return
  fi
  log "Instalando Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code instalado"
}

# Configura a statusline do Claude Code com o layout deste repositório.
#
# A statusline é o ccstatusline, chamado via npx pelo settings.json do Claude.
# Ele mostra modelo, worktree, branch, alterações do git, uso de contexto,
# tempo de sessão, tempo do bloco e custo acumulado, em estilo powerline.
configure_ccstatusline() {
  log "Configurando a statusline do Claude Code (ccstatusline)"

  local cfg_dir="$HOME/.config/ccstatusline"
  mkdir -p "$cfg_dir"

  if [ -f "$cfg_dir/settings.json" ]; then
    cp "$cfg_dir/settings.json" "$cfg_dir/settings.json.bak.$(date +%Y%m%d%H%M%S)"
    warn "Configuração anterior do ccstatusline salva como .bak"
  fi
  cp "$SETUP_DIR/config/ccstatusline-settings.json" "$cfg_dir/settings.json"
  ok "Layout da statusline aplicado"

  # Registra a statusline no settings.json do Claude Code, preservando o resto.
  local claude_dir="$HOME/.claude"
  mkdir -p "$claude_dir"
  local settings="$claude_dir/settings.json"
  [ -f "$settings" ] || echo '{}' > "$settings"

  python3 - "$settings" <<'PY'
import json, io, sys
p = sys.argv[1]
try:
    with io.open(p, encoding='utf-8') as f:
        data = json.load(f)
except Exception:
    data = {}
data['statusLine'] = {"type": "command", "command": "npx -y ccstatusline@latest", "padding": 0}
with io.open(p, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
PY
  ok "statusLine registrada em ~/.claude/settings.json"

  # A fonte do terminal precisa ter os glifos powerline, senão as setas
  # aparecem como quadrados. Nerd Font resolve.
  warn "Defina uma Nerd Font no terminal (ex.: MesloLGS NF) para os separadores"
}
