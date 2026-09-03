#!/usr/bin/env bash
#
# Gera um pacote portável com as configurações do Claude Code e do terminal.
#
#   ./backup-claude.sh [destino]        # padrão: ~/dev/backup-ambiente-AAAAMMDD
#
# NÃO inclui segredo algum: credenciais de MCP viram placeholders e o
# arquivo de autenticação do Claude fica de fora.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

OUT="${1:-$HOME/dev/backup-ambiente-$(date +%Y%m%d)}"
log "Gerando backup em $OUT"
rm -rf "$OUT"; mkdir -p "$OUT"/{claude,config,shell,inventario}

cp "$HOME/.claude/settings.json" "$OUT/claude/" 2>/dev/null && ok "settings.json"
cp "$HOME/.claude/CLAUDE.md"     "$OUT/claude/" 2>/dev/null && ok "CLAUDE.md"
for d in skills commands scripts; do
  [ -d "$HOME/.claude/$d" ] && cp -R "$HOME/.claude/$d" "$OUT/claude/" && ok "$d"
done
mkdir -p "$OUT/claude/mcp-servers"
cp "$HOME"/.claude/mcp-servers/*.jar "$OUT/claude/mcp-servers/" 2>/dev/null

mkdir -p "$OUT/claude/projects"
n=0
for d in "$HOME"/.claude/projects/*/memory; do
  [ -d "$d" ] || continue
  slug=$(basename "$(dirname "$d")")
  mkdir -p "$OUT/claude/projects/$slug"
  cp -R "$d" "$OUT/claude/projects/$slug/memory"
  n=$((n + $(find "$d" -name '*.md' | wc -l)))
done
ok "$n arquivos de memória"

# Estrutura dos MCP servers, com toda chave sensível substituída.
python3 - "$OUT/claude/mcp-servers.template.json" <<'PY'
import json, io, os, sys, re
try:
    d = json.load(io.open(os.path.expanduser('~/.claude.json'), encoding='utf-8'))
except Exception:
    d = {}
SECRET = re.compile(r'(key|token|password|secret|authorization|passwd)', re.I)
def scrub(o, path=""):
    if isinstance(o, dict):
        return {k: ("<DEFINIR_" + k.upper() + ">" if SECRET.search(k) else scrub(v, k)) for k, v in o.items()}
    if isinstance(o, list): return [scrub(x) for x in o]
    if isinstance(o, str) and SECRET.search(path): return "<DEFINIR>"
    return o
io.open(sys.argv[1], 'w', encoding='utf-8').write(
    json.dumps({"mcpServers": scrub(d.get('mcpServers', {}))}, indent=2, ensure_ascii=False))
PY
ok "mcp-servers.template.json (sem segredos)"

cp "$HOME/.config/ccstatusline/settings.json" "$OUT/config/ccstatusline-settings.json" 2>/dev/null && ok "ccstatusline"
cp "$HOME/.zshrc" "$OUT/shell/.zshrc" 2>/dev/null && ok ".zshrc"

brew list --formula > "$OUT/inventario/brew-formulas.txt" 2>/dev/null
brew list --cask    > "$OUT/inventario/brew-casks.txt"    2>/dev/null
npm ls -g --depth=0 > "$OUT/inventario/npm-globais.txt"   2>/dev/null
ls "$HOME/.sdkman/candidates/java" > "$OUT/inventario/java-sdkman.txt" 2>/dev/null
ok "inventário do que estava instalado"

# Rede de segurança: varre o pacote atrás de credencial antes de liberar a cópia.
#
# Duas passadas, porque segredo aparece em dois formatos diferentes:
#   1. configuração  ->  "password": "abc123..."
#   2. prosa         ->  a senha do Mongo (`abc123...`) precisa de rotação
#
# A segunda existe porque anotações de análise costumam citar o valor no meio
# do texto, sem dois-pontos nem aspas — e é justamente o caso que passa batido.
log "Procurando credenciais no pacote"
SUSPEITOS=$(mktemp)

grep -rlEi "(api[_-]?key|password|passwd|secret|token|authorization)\"?[[:space:]]*[:=][[:space:]]*[\"'][A-Za-z0-9_.\-]{12,}" \
  "$OUT" 2>/dev/null >> "$SUSPEITOS"

# Linha que menciona credencial E carrega um valor entre aspas ou crases.
# O limiar é 12 e não 16: senha real costuma ser mais curta que token de API,
# e foi exatamente isso que deixou um valor de 15 caracteres passar antes.
grep -rlEi "(api[_-]?key|password|passwd|secret|token|credencial|senha).{0,60}[\"'\`][A-Za-z0-9_.\-]{12,}[\"'\`]" \
  "$OUT" 2>/dev/null >> "$SUSPEITOS"

if [ -s "$SUSPEITOS" ]; then
  warn "possível credencial nestes arquivos — revise antes de copiar:"
  sort -u "$SUSPEITOS" | sed "s|$OUT|  .|"
  warn "edite o arquivo e substitua o valor por <REDIGIDO> antes de levar o pacote"
else
  ok "nenhuma credencial detectada"
fi
rm -f "$SUSPEITOS"

log "Backup pronto: $OUT  ($(du -sh "$OUT" | cut -f1))"
