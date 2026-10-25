#!/usr/bin/env bash
set -eu

hook_input="$(cat)"
if printf '%s' "$hook_input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  printf '{"decision":"allow"}\n'
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'Review hook skipped: Git is unavailable.' >&2
  printf '{}\n'
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf '%s\n' 'Review hook skipped: current directory is not a Git work tree.' >&2
  printf '{}\n'
  exit 0
fi

if ! changes="$(git status --porcelain --untracked-files=all 2>&1)"; then
  printf 'Review hook failed to inspect Git changes: %s\n' "$changes" >&2
  exit 1
fi

if [ -z "$changes" ]; then
  printf '{"decision":"allow"}\n'
  exit 0
fi

printf '%s\n' '{"decision":"block","reason":"Review the changed files against .github/copilot-instructions.md and applicable project conventions. Then run /security-review on the staged and unstaged changes. Fix confirmed issues with minimal changes, or report findings and any checks not run. After that review, finish with a concise summary."}'
