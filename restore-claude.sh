#!/usr/bin/env bash
#
# Restaura as configurações pessoais do Claude Code a partir de um backup
# gerado por backup-claude.sh.
#
#   ./restore-claude.sh ~/dev/backup-ambiente-AAAAMMDD
#
# O backup não contém segredos nem MCP servers — estes últimos são registrados
# à mão com "claude mcp add", já que dependem de credencial e de infraestrutura
# específicas de cada máquina.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

BACKUP="${1:-}"
if [ -z "$BACKUP" ] || [ ! -d "$BACKUP" ]; then
  echo "uso: $0 /caminho/do/backup-ambiente-AAAAMMDD" >&2
  exit 1
fi
if [ ! -f "$BACKUP/.setup-dev-backup" ]; then
  echo "'$BACKUP' não parece um backup gerado por backup-claude.sh." >&2
  echo "Falta o marcador .setup-dev-backup — confira o caminho." >&2
  exit 1
fi

log "Restaurando a partir de $BACKUP"
mkdir -p "$HOME/.claude" "$HOME/.config/ccstatusline"

restore() {  # origem destino descrição
  [ -e "$1" ] || { warn "não encontrado no backup: $3"; return; }
  if [ -e "$2" ]; then
    mv "$2" "$2.bak.$(date +%Y%m%d%H%M%S)"
    warn "$3 anterior salvo como .bak"
  fi
  cp -R "$1" "$2"
  ok "$3"
}

restore "$BACKUP/claude/CLAUDE.md"                "$HOME/.claude/CLAUDE.md"                "instruções globais"
restore "$BACKUP/claude/skills"                   "$HOME/.claude/skills"                   "skills"
restore "$BACKUP/claude/commands"                 "$HOME/.claude/commands"                 "slash commands"
restore "$BACKUP/claude/scripts"                  "$HOME/.claude/scripts"                  "scripts"
restore "$BACKUP/config/ccstatusline-settings.json" "$HOME/.config/ccstatusline/settings.json" "layout da statusline"

# As memórias ficam por projeto, em ~/.claude/projects/<slug>/memory.
if [ -d "$BACKUP/claude/projects" ]; then
  log "Restaurando memórias"
  n=0
  for p in "$BACKUP/claude/projects"/*; do
    [ -d "$p/memory" ] || continue
    slug=$(basename "$p")
    mkdir -p "$HOME/.claude/projects/$slug"
    cp -R "$p/memory" "$HOME/.claude/projects/$slug/"
    n=$((n + $(find "$p/memory" -name '*.md' | wc -l)))
  done
  ok "$n arquivos de memória restaurados"
fi

# settings.json: mescla o do backup com o que já existe, sem descartar nada.
if [ -f "$BACKUP/claude/settings.json" ]; then
  log "Mesclando settings.json"
  python3 - "$BACKUP/claude/settings.json" "$HOME/.claude/settings.json" <<'PY'
import json, io, sys
src, dst = sys.argv[1], sys.argv[2]
def load(p):
    try:
        with io.open(p, encoding='utf-8') as f: return json.load(f)
    except Exception: return {}
merged = load(dst)
merged.update(load(src))
with io.open(dst, 'w', encoding='utf-8') as f:
    json.dump(merged, f, indent=2, ensure_ascii=False); f.write('\n')
PY
  ok "settings.json mesclado"
fi

ok "Restauração concluída. Abra o Claude Code para conferir a statusline."
