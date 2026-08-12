#!/usr/bin/env bash
# copilot-power-pack — install curated agents / instructions / skills from
# github/awesome-copilot into a project's .github/ folder.
#
#   ./install.sh                       # installs the "core" pack into .
#   ./install.sh core docs             # installs several packs
#   ./install.sh all --target ~/work/app
#   ./install.sh --list                # show packs and what's in them
#
# Only the files you asked for are downloaded (one API call for the file
# listing, then parallel raw fetches) — no multi-hundred-MB repo tarball.
#
set -euo pipefail

UPSTREAM_OWNER="github/awesome-copilot"
UPSTREAM_REF="main"
TREE_API="https://api.github.com/repos/$UPSTREAM_OWNER/git/trees/$UPSTREAM_REF?recursive=1"
RAW_BASE="https://raw.githubusercontent.com/$UPSTREAM_OWNER/$UPSTREAM_REF"
PACK_REMOTE="https://raw.githubusercontent.com/Sachin619619/copilot-power-pack/main/packs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
PACK_DIR="${SCRIPT_DIR:+$SCRIPT_DIR/packs}"
ALL_PACKS="core coding docs quality planning web backend meta"

TARGET="."
PACKS=()
DRY_RUN=0
ALSO_CLAUDE=0
JOBS=8

die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
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
  cat <<'EOF'
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
  --jobs N       parallel downloads (default 8)
  -h, --help     this message
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:-}"; [ -n "$TARGET" ] || die "--target needs a directory"; shift 2 ;;
    --jobs)   JOBS="${2:-8}"; shift 2 ;;
    --claude) ALSO_CLAUDE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --list)
      for p in $ALL_PACKS; do
        printf '\n\033[1m%s\033[0m\n' "$p"
        read_pack "$p" | grep -v '^#' | grep -v '^[[:space:]]*$' | sed 's/^/  /'
      done
      exit 0 ;;
    -h|--help) usage; exit 0 ;;
    all) PACKS=($ALL_PACKS); shift ;;
    -*) die "unknown option $1" ;;
    *) PACKS+=("$1"); shift ;;
  esac
done

[ ${#PACKS[@]} -eq 0 ] && PACKS=(core)
command -v curl >/dev/null || die "curl is required"

mkdir -p "$TARGET" || die "cannot create $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

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

# One API call gets every path in the upstream repo. Skills are folders that
# may bundle references/ and scripts, so we need the real file listing rather
# than guessing at SKILL.md.
info "fetching upstream file index ..."
curl -fsSL -H 'Accept: application/vnd.github+json' "$TREE_API" -o "$TMP/tree.json" \
  || die "could not reach the GitHub API (rate limited? try again in a minute)"
# Blobs only — directory ("tree") entries are not downloadable.
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys
d=json.load(open(sys.argv[1]))
for e in d.get("tree",[]):
    if e.get("type")=="blob": print(e["path"])' "$TMP/tree.json" | sort -u > "$TMP/paths.txt"
else
  tr '{' '\n{' < "$TMP/tree.json" \
    | awk -F'"' '/"path"[[:space:]]*:/{p=$4} /"type"[[:space:]]*:[[:space:]]*"blob"/{if(p!=""){print p; p=""}}' \
    | sort -u > "$TMP/paths.txt"
fi
[ -s "$TMP/paths.txt" ] || die "could not parse the upstream file index"

# Resolve each pack entry to the concrete upstream paths it needs.
: > "$TMP/files.txt"
n_miss=0
while IFS= read -r line; do
  kind="${line%%:*}"; name="${line#*:}"
  case "$kind" in
    agent) want="agents/$name.agent.md" ;;
    instr) want="instructions/$name.instructions.md" ;;
    skill) want="skills/$name/" ;;
    *) warn "skipping malformed line: $line"; continue ;;
  esac
  if [ "$kind" = "skill" ]; then
    if grep -q "^skills/$name/" "$TMP/paths.txt"; then
      grep "^skills/$name/" "$TMP/paths.txt" >> "$TMP/files.txt"
      ok "skill  $name"
    else
      warn "skill  $name — not found upstream"; n_miss=$((n_miss+1))
    fi
  else
    if grep -qx "$want" "$TMP/paths.txt"; then
      echo "$want" >> "$TMP/files.txt"
      [ "$kind" = agent ] && ok "agent  $name" || ok "instr  $name"
    else
      warn "$kind  $name — not found upstream"; n_miss=$((n_miss+1))
    fi
  fi
done <<< "$ENTRIES"

sort -u "$TMP/files.txt" -o "$TMP/files.txt"
N_FILES="$(wc -l < "$TMP/files.txt" | tr -d ' ')"
[ "$N_FILES" -gt 0 ] || die "nothing to download"

info "downloading $N_FILES file(s) ..."
mkdir -p "$TARGET/.github/agents" "$TARGET/.github/instructions" "$TARGET/.github/skills"

export RAW_BASE TARGET
fetch_one() {
  path="$1"
  dest="$TARGET/.github/$path"
  mkdir -p "$(dirname "$dest")"
  curl -fsSL --retry 3 --retry-delay 1 "$RAW_BASE/$path" -o "$dest" || { echo "FAILED $path" >&2; return 1; }
}
export -f fetch_one

n_fail=0
xargs -P "$JOBS" -I{} bash -c 'fetch_one "$@"' _ {} < "$TMP/files.txt" || n_fail=1

if [ "$ALSO_CLAUDE" = "1" ] && [ -d "$TARGET/.github/skills" ]; then
  mkdir -p "$TARGET/.claude/skills"
  cp -R "$TARGET/.github/skills/." "$TARGET/.claude/skills/"
  info "mirrored skills into .claude/skills/"
fi

echo
if [ "$n_miss" -gt 0 ]; then
  info "done — $N_FILES file(s) written, $n_miss item(s) not found upstream"
else
  info "done — $N_FILES file(s) written"
fi
[ "$n_fail" = "1" ] && warn "some downloads failed; re-run to retry"

cat <<EOF

Where things landed:
  $TARGET/.github/agents/        *.agent.md         — pick from the VS Code Chat agent dropdown
  $TARGET/.github/instructions/  *.instructions.md  — auto-applied by file glob, always on
  $TARGET/.github/skills/        <name>/SKILL.md    — loaded on demand when relevant

Reload VS Code (Cmd/Ctrl+Shift+P -> "Developer: Reload Window") to pick them up.
EOF
