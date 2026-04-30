#!/usr/bin/env bash
set -euo pipefail

input="$(cat || true)"

tool_name="$(
  printf '%s' "$input" \
    | sed -nE 's/.*"tool[Nn]ame"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
    | head -n 1
)"

case "$tool_name" in
  "" | Edit | Write | MultiEdit | edit | write | create | ApplyPatch | apply_patch)
    ;;
  *)
    exit 0
    ;;
esac

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
  exit 0
fi

cd "$repo_root"

if [ "${AI_AFTER_WORK_IN_NIX:-}" != "1" ] && command -v nix >/dev/null 2>&1 && [ -f flake.nix ]; then
  exec env AI_AFTER_WORK_IN_NIX=1 nix develop "path:$repo_root" -c "$0"
fi

changed_files="$(
  {
    git diff --name-only --diff-filter=ACMRTUXB -- .
    git diff --cached --name-only --diff-filter=ACMRTUXB -- .
    git ls-files --others --exclude-standard
  } | sort -u
)"

if [ -z "$changed_files" ]; then
  exit 0
fi

nix_files="$(printf '%s\n' "$changed_files" | sed -n '/\.nix$/p')"
lua_files="$(printf '%s\n' "$changed_files" | sed -n '/\.lua$/p')"

if [ -n "$nix_files" ]; then
  if ! command -v nixfmt >/dev/null 2>&1; then
    echo "nixfmt is not available; run nix develop first" >&2
    exit 1
  fi

  printf '%s\n' "$nix_files" | xargs nixfmt

  if command -v deadnix >/dev/null 2>&1; then
    printf '%s\n' "$nix_files" | xargs deadnix --fail
  fi

  if command -v statix >/dev/null 2>&1; then
    statix check .
  fi
fi

if [ -n "$lua_files" ]; then
  if ! command -v stylua >/dev/null 2>&1; then
    echo "stylua is not available; run nix develop first" >&2
    exit 1
  fi

  printf '%s\n' "$lua_files" | xargs stylua
fi
