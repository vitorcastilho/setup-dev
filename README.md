# setup-dev

Provisiona uma máquina de desenvolvimento do zero — **macOS** ou **Linux (Ubuntu/Debian)** — e leva as configurações pessoais de uma máquina para outra, sem carregar segredo junto.

O objetivo é ter o mesmo ambiente nos dois sistemas: as mesmas ferramentas, a mesma versão de cada linguagem e a mesma configuração do Claude Code, incluindo a statusline.

Todos os scripts são **idempotentes** — podem rodar mais de uma vez sem quebrar nada. Cada etapa verifica se já foi feita antes de agir.

---

## Uso

### Numa máquina nova

```bash
git clone https://github.com/vitorcastilho/setup-dev
cd setup-dev

./setup-dev-macos.sh     # macOS
./setup-dev-linux.sh     # Linux (Ubuntu/Debian)
```

Depois, restaure as configurações pessoais a partir de um backup:

```bash
./restore-claude.sh ~/dev/backup-ambiente-AAAAMMDD
```

### Antes de entregar ou formatar uma máquina

```bash
./backup-claude.sh
```

Gera o pacote em `~/dev/backup-ambiente-AAAAMMDD`. Copie a pasta antes de formatar.

---

## O que é instalado

| | |
|---|---|
| **Terminal** | Warp |
| **Fonte** | Meslo Nerd Font |
| **Linguagens** | Java 17 e 21 via SDKMAN (17 como padrão), Node LTS via NVM |
| **Gerenciadores** | npm, Yarn |
| **Containers** | Docker |
| **IA** | Claude Code, com a statusline configurada |
| **Bancos** | DBeaver e, no macOS, MongoDB Compass |
| **IDEs** | VS Code, IntelliJ IDEA CE, Postman |
| **CLI** | git, gh, curl, wget, jq, gnupg, unzip |

As versões de Java e Node ficam no topo dos scripts, num único lugar, para facilitar a troca.

---

## Depois de rodar

Três coisas dependem de você e os scripts não têm como fazer:

1. **Selecionar a fonte no terminal.** A Meslo Nerd Font é instalada, mas precisa ser escolhida: `Settings → Appearance → Text → MesloLGS Nerd Font`. Sem isso, os separadores da statusline aparecem como quadrados.
2. **Autenticar o Claude Code** — `claude`
3. **Autenticar o GitHub CLI** — `gh auth login`

---

## A statusline do Claude Code

A barra no topo do Claude Code — modelo, worktree, branch, alterações do git, uso de contexto, tempo de sessão, tempo do bloco e custo acumulado — é o [ccstatusline](https://github.com/sirmalloc/ccstatusline), chamado via `npx` pelo `settings.json` do Claude. **Não é recurso do terminal.**

O layout deste repositório está em `config/ccstatusline-settings.json` — powerline, tema `nord-aurora`, em três linhas:

```
modelo · worktree · branch · alterações
contexto · % usado · % usável
sessão · bloco · custo
```

Os scripts copiam o arquivo para `~/.config/ccstatusline/settings.json` e registram a `statusLine` no `~/.claude/settings.json`. O registro é feito com merge: **as demais chaves do settings são preservadas**, não sobrescritas.

---

## Backup e restauração

### O que vai no pacote

- `settings.json` e `CLAUDE.md`
- skills, slash commands e scripts
- **as memórias por projeto** (`~/.claude/projects/*/memory`)
- o layout do ccstatusline e o `.zshrc`
- inventário do que estava instalado: brew formulas e casks, pacotes npm globais, versões de Java

### O que não vai, e por quê

**Segredo, em nenhuma forma.** O arquivo de autenticação do Claude fica de fora, e o script varre o pacote antes de terminar, em duas passadas: uma para o formato de configuração (`password: "valor"`) e outra para menções em texto corrido, que é como segredo costuma aparecer em anotação de análise. Se algo for detectado, o script avisa quais arquivos revisar.

**MCP servers.** Dependem de credencial e de infraestrutura específicas de cada máquina e de cada trabalho, e vão sendo personalizados ao longo do uso. São registrados à mão com `claude mcp add` quando fizerem falta.

### Restauração

`restore-claude.sh` salva como `.bak` qualquer arquivo que já exista antes de substituir, e faz merge do `settings.json` em vez de sobrescrever. Rodar duas vezes não perde nada.

---

## Estrutura

```
setup-dev/
├── setup-dev-macos.sh              provisionamento do macOS
├── setup-dev-linux.sh              provisionamento do Linux
├── backup-claude.sh                gera o pacote de configurações
├── restore-claude.sh               restaura o pacote numa máquina nova
├── lib/
│   └── common.sh                   funções compartilhadas pelos scripts
└── config/
    └── ccstatusline-settings.json  layout da statusline
```
