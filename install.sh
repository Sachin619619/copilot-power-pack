#!/usr/bin/env bash
# copilot-power-pack — install curated agents / instructions / skills from
# github/awesome-copilot into a project's .github/ folder.
#
#   ./install.sh                       # installs the "core" pack into .
#   ./install.sh core docs             # installs several packs
#   ./install.sh all --target ~/work/app
#   ./install.sh --list                # show packs and what's in them
#
set -euo pipefail

UPSTREAM_TARBALL="https://codeload.github.com/github/awesome-copilot/tar.gz/refs/heads/main"
PACK_REMOTE="https://raw.githubusercontent.com/Sachin619619/copilot-power-pack/main/packs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
PACK_DIR="${SCRIPT_DIR:+$SCRIPT_DIR/packs}"
ALL_PACKS="core coding docs quality planning web backend meta"

TARGET="."
PACKS=()
DRY_RUN=0
ALSO_CLAUDE=0

die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[32m+\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }

read_pack() {
  local name="$1"
  if [ -n "$PACK_DIR" ] && [ -f "$PACK_DIR/$name.txt" ]; then
    cat "$PACK_DIR/$name.txt"
  else
    curl -fsSL "$PACK_REMOTE/$name.txt" || die "unknown pack '$name'"
  fi
}

usage() {
  cat <<EOF
copilot-power-pack

Usage: install.sh [PACK...] [options]

Packs:
  core      14 essentials — start here
  coding    writing, refactoring, debugging, TDD
  docs      READMEs, ADRs, tutorials, diagrams, doc-drift prevention
  quality   code review, security, testing
  planning  specs, implementation plans, task breakdown
  web       React / Next.js / TypeScript / Tailwind / a11y
  backend   Go / Rust / shell / SQL / Docker / CI
  meta      bootstrap a repo's own Copilot config + discovery skills
  all       everything above

Options:
  --target DIR   project to install into (default: current directory)
  --claude       also mirror skills into .claude/skills/ for Claude Code
  --list         print packs and their contents, then exit
  --dry-run      show what would be installed, change nothing
  -h, --help     this message
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:-}"; [ -n "$TARGET" ] || die "--target needs a directory"; shift 2 ;;
    --claude) ALSO_CLAUDE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --list)
      for p in $ALL_PACKS; do
        printf '\n\033[1m%s\033[0m\n' "$p"
        read_pack "$p" | grep -v '^#' | grep -v '^$' | sed 's/^/  /'
      done
      exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option $1" ;;
    all) PACKS=($ALL_PACKS); shift ;;
    *) PACKS+=("$1"); shift ;;
  esac
done

[ ${#PACKS[@]} -eq 0 ] && PACKS=(core)
command -v curl >/dev/null || die "curl is required"
command -v tar  >/dev/null || die "tar is required"

mkdir -p "$TARGET" || die "cannot create $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

# Collect + dedupe the entry list across the requested packs.
ENTRIES="$(for p in "${PACKS[@]}"; do read_pack "$p"; done \
  | grep -v '^#' | grep -v '^[[:space:]]*$' | sort -u)"
COUNT="$(printf '%s\n' "$ENTRIES" | wc -l | tr -d ' ')"

info "packs:  ${PACKS[*]}"
info "target: $TARGET"
info "items:  $COUNT"

if [ "$DRY_RUN" = "1" ]; then
  printf '%s\n' "$ENTRIES" | sed 's/^/  /'
  info "dry run — nothing written"
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

info "downloading github/awesome-copilot ..."
curl -fsSL "$UPSTREAM_TARBALL" -o "$TMP/src.tar.gz" || die "download failed"
tar -xzf "$TMP/src.tar.gz" -C "$TMP" || die "extract failed"
SRC="$TMP/awesome-copilot-main"
[ -d "$SRC" ] || die "unexpected archive layout"

mkdir -p "$TARGET/.github/agents" "$TARGET/.github/instructions" "$TARGET/.github/skills"
[ "$ALSO_CLAUDE" = "1" ] && mkdir -p "$TARGET/.claude/skills"

n_ok=0; n_miss=0
while IFS= read -r line; do
  kind="${line%%:*}"; name="${line#*:}"
  case "$kind" in
    agent)
      src="$SRC/agents/$name.agent.md"
      if [ -f "$src" ]; then cp "$src" "$TARGET/.github/agents/"; ok "agent  $name"; n_ok=$((n_ok+1))
      else warn "agent  $name — not found upstream"; n_miss=$((n_miss+1)); fi ;;
    instr)
      src="$SRC/instructions/$name.instructions.md"
      if [ -f "$src" ]; then cp "$src" "$TARGET/.github/instructions/"; ok "instr  $name"; n_ok=$((n_ok+1))
      else warn "instr  $name — not found upstream"; n_miss=$((n_miss+1)); fi ;;
    skill)
      src="$SRC/skills/$name"
      if [ -d "$src" ]; then
        rm -rf "$TARGET/.github/skills/$name"
        cp -R "$src" "$TARGET/.github/skills/"
        if [ "$ALSO_CLAUDE" = "1" ]; then
          rm -rf "$TARGET/.claude/skills/$name"
          cp -R "$src" "$TARGET/.claude/skills/"
        fi
        ok "skill  $name"; n_ok=$((n_ok+1))
      else warn "skill  $name — not found upstream"; n_miss=$((n_miss+1)); fi ;;
    *) warn "skipping malformed line: $line" ;;
  esac
done <<< "$ENTRIES"

echo
if [ "$n_miss" -gt 0 ]; then
  info "installed $n_ok item(s), $n_miss missing"
else
  info "installed $n_ok item(s)"
fi
cat <<EOF

Where things landed:
  $TARGET/.github/agents/        *.agent.md         — pick from the VS Code Chat agent dropdown
  $TARGET/.github/instructions/  *.instructions.md  — auto-applied by file glob, always on
  $TARGET/.github/skills/        <name>/SKILL.md    — loaded on demand when relevant

Reload VS Code (Cmd/Ctrl+Shift+P -> "Developer: Reload Window") to pick them up.
EOF
