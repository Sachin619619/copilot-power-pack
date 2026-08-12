# 🚀 Copilot Power Pack

A curated, opinionated slice of [`github/awesome-copilot`](https://github.com/github/awesome-copilot) — the best **agents**, **instructions**, and **skills** for **writing code** and **writing documentation**, plus one-command installers.

Upstream has 224 agents, 192 instructions and 407 skills. This repo picks the **145** that actually earn their place, groups them into packs, and gives you copy-paste commands.

> Verified against upstream `main` on **12 Aug 2026**. Every item listed here was HTTP-checked and exists.
> `install.sh all` pulls 303 files in ~15 seconds — it fetches only what you asked for, never the (very large) upstream repo tarball.

---

## ⚡ Quick start

Run this inside the project you want to power up:

```bash
curl -fsSL https://raw.githubusercontent.com/Sachin619619/copilot-power-pack/main/install.sh | bash -s -- core
```

Want the full coding + documentation setup:

```bash
curl -fsSL https://raw.githubusercontent.com/Sachin619619/copilot-power-pack/main/install.sh | bash -s -- core coding docs quality planning meta
```

Everything, including the language packs:

```bash
curl -fsSL https://raw.githubusercontent.com/Sachin619619/copilot-power-pack/main/install.sh | bash -s -- all
```

Or clone and run it locally:

```bash
git clone https://github.com/Sachin619619/copilot-power-pack.git
cd copilot-power-pack
./install.sh --list                       # see every pack and its contents
./install.sh core docs --target ~/work/my-app
./install.sh all --claude                 # also mirror skills into .claude/skills/
./install.sh coding --dry-run             # preview, change nothing
```

Then reload VS Code: `Cmd/Ctrl+Shift+P` → **Developer: Reload Window**.

### Where files land

| Type | Path | How it activates |
|---|---|---|
| Agents | `.github/agents/*.agent.md` | Pick from the agent dropdown in VS Code Chat |
| Instructions | `.github/instructions/*.instructions.md` | **Automatic** — applied by file glob, always on |
| Skills | `.github/skills/<name>/SKILL.md` | Loaded on demand when the task matches |

---

## 📦 Packs

| Pack | What it is | Items |
|---|---|---|
| `core` | The 14 essentials. If you install nothing else, install this. | 14 |
| `coding` | Writing, refactoring, debugging, TDD | 30 |
| `docs` | READMEs, ADRs, tutorials, diagrams, doc-drift prevention | 38 |
| `quality` | Code review, security, testing | 18 |
| `planning` | Specs, implementation plans, task breakdown | 18 |
| `web` | React / Next.js / TypeScript / Tailwind / a11y | 15 |
| `backend` | Go / Rust / shell / SQL / Docker / CI | 12 |
| `meta` | Bootstrap a repo's own Copilot config + discovery skills | 12 |
| `all` | Everything — 145 unique items, 35 agents + 33 instructions + 77 skills | 145 |

---

## 🤖 Best agents

### For coding

| Agent | Why it's here |
|---|---|
| **`software-engineer-agent-v1`** | **The daily driver.** Expert-level, spec-driven, production-ready-code mandate, zero-confirmation autonomous execution. Full tool belt: `runTests`, `problems`, `findTestFiles`, `usages`, `runCommands`. |
| **`blueprint-mode`** | v39. Four workflows — Debug / Express / Main / Loop. The strictest agent in the repo on correctness, self-correction and edge cases. Blunt senior-engineer persona. Heavy (~11k chars). |
| **`principal-software-engineer`** | Martin Fowler-flavored. SOLID, GoF patterns, test pyramid, quality attributes. Best **reviewer/advisor** — won't grind out code for you. |
| **`swe-subagent`** | Lean and sharp: minimal correct diffs, tests non-optional, "discover architecture, never guess". Best agent to delegate to. |
| **`qa-subagent`** | Its QA counterpart. |
| **`debug`** | Focused debugging loop. |
| **`janitor`** | Universal tech-debt removal. Philosophy: "less code = less debt", deletion is the most powerful refactoring. |
| **`wg-code-alchemist`** | Clean Code + SOLID transformation of existing code. |
| **`tdd-red` / `tdd-green` / `tdd-refactor`** | Proper three-phase TDD cycle, one agent per phase. |
| **`address-comments`** | Works through PR review comments. |
| **`api-architect`** / **`repo-architect`** | API and repo structure design. |
| **`critical-thinking`** | Refuses to write code — only asks "why?" until your assumptions break. Use it *before* you build. |
| **`expert-react-frontend-engineer`** / **`expert-nextjs-developer`** | Stack-specific expertise. |

### For documentation

| Agent | Why it's here |
|---|---|
| **`project-documenter`** | Whole-project documentation generation. |
| **`se-technical-writer`** | Professional technical writing voice. |
| **`code-tour`** | Generates a guided walkthrough of a codebase — brilliant for onboarding. |
| **`adr-generator`** | Architecture Decision Records. |
| **`specification`** | Formal spec documents. |
| **`technical-content-evaluator`** | Grades your docs and tells you what's weak. |
| **`markdown-accessibility-assistant`** | Makes Markdown actually accessible. |

### For quality & security

`quality-playbook` · `wg-code-sentinel` · `se-security-reviewer` · `se-system-architecture-reviewer` · `doublecheck`

### For planning

`task-planner` · `task-researcher` · `implementation-plan` · `plan` · `planner`

---

## 📋 Best instructions

**This is the highest-leverage folder in the whole upstream repo, and it's the one everyone skips.** Agents have to be invoked; instructions apply automatically by file glob, on every single request. This is what actually enforces your coding standards.

### Universal — install these everywhere

| Instruction | What it enforces |
|---|---|
| `security-and-owasp` | OWASP Top 10 awareness on every file you touch 🔒 |
| `code-review-generic` | Consistent review criteria |
| `self-explanatory-code-commenting` | Comments that explain *why*, not *what* |
| `taming-copilot` | Stops Copilot going rogue and rewriting half your repo |
| `spec-driven-workflow-v1` | Spec → plan → implement discipline |
| `performance-optimization` | Perf-aware suggestions |
| `object-calisthenics` | Nine hard rules that force clean OO |
| `oop-design-patterns` | Pattern-aware refactoring |
| `qa-engineering-best-practices` | Test quality standards |
| `task-implementation` | Structured task execution |
| `memory-bank` | Persistent project context across sessions |

### Documentation

`markdown` · `markdown-gfm` · `markdown-content-creation` · `markdown-accessibility` · **`update-docs-on-code-change`** ← this one alone kills doc drift

### Web stack

`nextjs` · `nextjs-tailwind` · `tailwind-v4-vite` · `nodejs-javascript-vitest` · `playwright-typescript` · `a11y` · `vue` · `svelte`

### Backend / infra

`go` · `rust` · `shell` · `containerization-docker-best-practices` · `github-actions-ci-cd-best-practices` · `devops-core-principles`

### Meta (for writing your own)

`agents` · `instructions` · `prompt`

> ⚠️ **Known gap:** upstream has **no general `python.instructions.md`** — only `langchain-python` and `playwright-python`. For Python projects, use the `write-coding-standards-from-file` skill to generate one from an exemplar file.

---

## 🎯 Best skills

### Documentation

| Skill | What it does |
|---|---|
| `documentation-writer` | General-purpose doc authoring |
| `create-readme` / `readme-blueprint-generator` | READMEs — the second one derives structure from your actual codebase |
| `create-architectural-decision-record` | ADRs |
| `oo-component-documentation` | Per-component docs |
| `comment-code-generate-a-tutorial` | Turns annotated code into a tutorial |
| `add-educational-comments` | Teaching-quality inline comments |
| `create-llms` / `update-llms` | `llms.txt` so AI tools can read your project |
| `create-agentsmd` | Generates `AGENTS.md` |
| `code-tour` | Guided codebase walkthrough |
| `repo-story-time` | Narrative history of a repo from its git log |
| `doc-and-modernize` | Documents *and* modernizes legacy code in one pass |
| `architecture-blueprint-generator` / `folder-structure-blueprint-generator` | Reverse-engineers architecture docs from source |
| `drawio` / `excalidraw-diagram-generator` / `plantuml-ascii` | Diagrams 📊 |
| `markdown-to-html` / `md-to-docx` / `convert-pdf-to-md` / `convert-word-to-md` / `convert-excel-to-md` | Format conversion both ways |
| `update-markdown-file-index` / `create-tldr-page` | Doc housekeeping |

### Coding

| Skill | What it does |
|---|---|
| `refactor` / `review-and-refactor` / `refactor-method-complexity-reduce` | The refactoring trio |
| `diagnose` / `bug-reproduction-brief` | Debugging workflow |
| `acquire-codebase-knowledge` / `context-map` / `what-context-needed` | Get an agent oriented in an unfamiliar repo fast |
| `git-commit` / `conventional-commit` / `conventional-branch` / `github-release` | Git hygiene |
| `em-dash` | Strips em dashes — useful if you don't want output looking AI-written |

### Quality & security

| Skill | What it does |
|---|---|
| **`quality-playbook`** | ⭐ Six-phase audit, each phase in its own context window. Claims it finds the ~35% of real defects structural code review alone cannot catch. Ships as *both* an agent and a skill — install both. |
| `security-review` | Full security pass 🔒 |
| `codeql` / `secret-scanning` | Static analysis + leaked-credential hunting |
| `threat-model-analyst` | Threat modelling |
| `eval-driven-dev` | Eval-first development for AI features |
| `webapp-testing` / `pytest-coverage` / `javascript-typescript-jest` / `playwright-generate-test` | Testing |
| `incident-postmortem` | Blameless postmortems |

### Planning

`create-implementation-plan` · `update-implementation-plan` · `create-specification` · `update-specification` · `breakdown-feature-implementation` · `breakdown-plan` · `breakdown-test` · `structured-autonomy-{plan,implement,generate}`

### Meta — run these once per project 🧠

| Skill | What it does |
|---|---|
| `copilot-instructions-blueprint-generator` | Generates instructions tailored to **your actual codebase**. Best first move in any repo. |
| `technology-stack-blueprint-generator` | Documents your stack |
| `code-exemplars-blueprint-generator` | Extracts your house style from existing code |
| `project-workflow-analysis-blueprint-generator` | Maps how your team actually works |
| `suggest-awesome-github-copilot-agents` / `-instructions` / `-skills` | Points at your repo and recommends what else to install |

### Frontend

`anti-ui-slop` · `premium-frontend-ui` · `web-design-reviewer` · `chrome-devtools`

---

## 🔌 Official plugin bundles

Upstream also ships 94 plugins — pre-bundled sets. These need the **Copilot CLI**:

```bash
# if the marketplace isn't already registered
copilot plugin marketplace add github/awesome-copilot

copilot plugin install gem-team@awesome-copilot                  # 16-agent orchestrated dev team
copilot plugin install software-engineering-team@awesome-copilot # 7 agents: UX, arch, security, GitOps, PM, docs
copilot plugin install project-planning@awesome-copilot
copilot plugin install testing-automation@awesome-copilot
copilot plugin install context-engineering@awesome-copilot
copilot plugin install structured-autonomy@awesome-copilot       # expensive model plans, cheap model executes
copilot plugin install frontend-web-dev@awesome-copilot
copilot plugin install security-best-practices@awesome-copilot
```

**`gem-team`** is the standout: orchestrator → planner → implementer → reviewer → critic → debugger → simplifier → browser-tester → devops → designer → docs-writer, with real phase gates and automated verification. Closest thing to best-in-class full-lifecycle quality in the repo.

In VS Code you can also browse plugins via Extensions → search `@agentPlugins`, or Command Palette → **Chat: Plugins**.

---

## 🛠 Installing individual items

**Skills via GitHub CLI** (needs `gh` **v2.90.0+** — check with `gh --version`, upgrade with `brew upgrade gh`):

```bash
gh skills install github/awesome-copilot quality-playbook
gh skills install github/awesome-copilot documentation-writer
gh skills install github/awesome-copilot security-review
```

**Anything, with curl** — works on any machine, no CLI version requirements:

```bash
mkdir -p .github/agents .github/instructions

curl -fsSL -o .github/agents/software-engineer-agent-v1.agent.md \
  https://raw.githubusercontent.com/github/awesome-copilot/main/agents/software-engineer-agent-v1.agent.md

curl -fsSL -o .github/instructions/security-and-owasp.instructions.md \
  https://raw.githubusercontent.com/github/awesome-copilot/main/instructions/security-and-owasp.instructions.md
```

Pattern:
- agents → `https://raw.githubusercontent.com/github/awesome-copilot/main/agents/<name>.agent.md`
- instructions → `.../main/instructions/<name>.instructions.md`
- skills → `.../main/skills/<name>/SKILL.md` (skills are folders — may include `references/` and scripts, so prefer `install.sh` or `gh skills install`)

**Browse everything:** [awesome-copilot.github.com](https://awesome-copilot.github.com) — full-text search, filtering, one-click VS Code install buttons, and a machine-readable [`llms.txt`](https://awesome-copilot.github.com/llms.txt).

---

## ⚠️ A word on trust

Upstream content is contributed by third parties. Read an agent or skill file before you install it — prompt injection via skill files is a real attack surface. Upstream literally ships a `trojan-skill-hunter.agent.md` for this reason.

`install.sh` pulls straight from `github/awesome-copilot` `main`. It never executes anything it downloads; it only copies Markdown into `.github/`.

## License

Curation and `install.sh`: MIT. Upstream content remains under the [awesome-copilot](https://github.com/github/awesome-copilot) MIT license and belongs to its respective contributors.
