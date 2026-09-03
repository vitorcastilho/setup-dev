# setup-dev

Scripts para provisionar uma máquina de desenvolvimento do zero — **macOS** ou **Linux (Debian/Ubuntu)** — e restaurar as configurações pessoais do Claude Code.

Todos os scripts são **idempotentes**: podem rodar mais de uma vez sem quebrar nada.

---

## Uso

```bash
git clone https://github.com/vitorcastilho/setup-dev
cd setup-dev

./setup-dev-macos.sh     # macOS
./setup-dev-linux.sh           # Linux (Debian/Ubuntu)
```

Depois, se você tiver um backup das configurações:

```bash
./restore-claude.sh ~/dev/backup-ambiente-AAAAMMDD
```

E, antes de entregar ou formatar uma máquina:

```bash
./backup-claude.sh
```

---

## O que é instalado

| | |
|---|---|
| **Terminal** | Warp |
| **Fonte** | Meslo Nerd Font — necessária para os glifos da statusline |
| **Java** | SDKMAN com Zulu 17 (padrão) e 21 |
| **Node** | NVM com a versão LTS, mais Yarn |
| **Containers** | Docker |
| **IA** | Claude Code, com a statusline configurada |
| **Bancos** | DBeaver e, no macOS, MongoDB Compass |
| **IDEs** | VS Code, IntelliJ IDEA CE, Postman |
| **CLI** | git, gh, curl, wget, jq, gnupg, unzip |

---

## A statusline do Claude Code

A barra que aparece no topo do Claude Code — modelo, worktree, branch, alterações do git, uso de contexto, tempo de sessão, tempo do bloco e custo acumulado — é o [ccstatusline](https://github.com/sirmalloc/ccstatusline), chamado via `npx` pelo `settings.json` do Claude.

O layout deste repositório está em `config/ccstatusline-settings.json`, em estilo powerline com o tema `nord-aurora`, distribuído em três linhas:

```
Model · worktree · branch · alterações
contexto · % usado · % usável
sessão · bloco · custo
```

Os scripts copiam esse arquivo para `~/.config/ccstatusline/settings.json` e registram a `statusLine` no `~/.claude/settings.json`, **preservando o restante das configurações**.

> ⚠️ **Sem uma Nerd Font, os separadores viram quadrados.** No Warp: `Settings → Appearance → Text → MesloLGS Nerd Font`.

---

## Backup e restauração

`backup-claude.sh` gera um pacote portável com:

- `settings.json` e `CLAUDE.md`
- skills, slash commands e scripts
- **as memórias por projeto** (`~/.claude/projects/*/memory`)
- o layout do ccstatusline e o `.zshrc`
- inventário do que estava instalado (brew, npm global, versões de Java)

**Nenhum segredo entra no pacote.** As credenciais dos MCP servers viram placeholders em `mcp-servers.template.json`, o arquivo de autenticação do Claude fica de fora, e o script faz uma varredura final procurando padrões de credencial antes de terminar.

Como os MCP servers precisam de credencial, eles **não** são restaurados automaticamente — o template serve de referência para você registrá-los com `claude mcp add`.

---

## Estrutura

```
setup-dev/
├── setup-dev-macos.sh          provisionamento do macOS
├── setup-dev-linux.sh                provisionamento do Linux
├── backup-claude.sh            gera o pacote de configurações
├── restore-claude.sh           restaura o pacote numa máquina nova
├── lib/common.sh               funções compartilhadas
└── config/
    └── ccstatusline-settings.json
```
