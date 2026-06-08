#!/usr/bin/env bash
# Test auditable Contract-Driven TDD workflow behavior.
# Usage: ./run-scenarios.sh [max-turns]
#
# This is a workflow-level pressure test runner. Unlike tests/skill-triggering,
# it checks whether the agent output contains required contract markers and
# omits known-invalid markers.

set -euo pipefail

MAX_TURNS="${1:-8}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP="$(date +%s)"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/superpowers-tests/${TIMESTAMP}/auditable-contract-tdd}"
mkdir -p "$OUTPUT_DIR"

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ FAIL: claude command not found"
  echo "Install Claude Code or run in an environment with the claude CLI."
  exit 127
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️ jq not found; marker checks will use raw stream-json logs."
fi

pass_count=0
fail_count=0

check_marker() {
  local marker="$1"
  local text_file="$2"

  if [[ "$marker" == ABSENT:* ]]; then
    local forbidden="${marker#ABSENT: }"
    if grep -qF "$forbidden" "$text_file"; then
      echo "    ❌ forbidden marker present: $forbidden"
      return 1
    fi
    echo "    ✅ forbidden marker absent: $forbidden"
    return 0
  fi

  if [[ "$marker" == ANY:* ]]; then
    local alternatives="${marker#ANY: }"
    local found=false
    IFS='||' read -ra parts <<< "$alternatives"
    for part in "${parts[@]}"; do
      local trimmed
      trimmed="$(echo "$part" | sed 's/^ *//;s/ *$//')"
      if grep -qF "$trimmed" "$text_file"; then
        found=true
        break
      fi
    done
    if [[ "$found" == true ]]; then
      echo "    ✅ any marker present: $alternatives"
      return 0
    fi
    echo "    ❌ none of markers present: $alternatives"
    return 1
  fi

  if grep -qF "$marker" "$text_file"; then
    echo "    ✅ marker present: $marker"
    return 0
  fi

  echo "    ❌ missing marker: $marker"
  return 1
}

for scenario in "$SCRIPT_DIR"/scenarios/*.md; do
  id="$(basename "$scenario" .md | cut -d- -f1)"
  expected="$SCRIPT_DIR/expected/${id}-required-markers.md"
  name="$(basename "$scenario")"
  scenario_dir="$OUTPUT_DIR/$id"
  mkdir -p "$scenario_dir"
  log_file="$scenario_dir/agent-output.json"
  text_file="$scenario_dir/assistant-text.txt"

  echo "=== Scenario $id: $name ==="
  cp "$scenario" "$scenario_dir/prompt.md"

  prompt="$(cat "$scenario")"
  timeout 600 claude -p "$prompt" \
    --plugin-dir "$PLUGIN_DIR" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --output-format stream-json \
    > "$log_file" 2>&1 || true

  if command -v jq >/dev/null 2>&1; then
    jq -r '.. | objects | .text? // empty' "$log_file" > "$text_file" 2>/dev/null || cp "$log_file" "$text_file"
  else
    cp "$log_file" "$text_file"
  fi

  scenario_failed=false
  while IFS= read -r marker || [[ -n "$marker" ]]; do
    marker="$(echo "$marker" | sed 's/^ *//;s/ *$//')"
    [[ -z "$marker" || "$marker" == \#* ]] && continue
    if ! check_marker "$marker" "$text_file"; then
      scenario_failed=true
    fi
  done < "$expected"

  if [[ "$scenario_failed" == true ]]; then
    echo "❌ FAIL scenario $id"
    echo "   Output: $text_file"
    fail_count=$((fail_count + 1))
  else
    echo "✅ PASS scenario $id"
    pass_count=$((pass_count + 1))
  fi
  echo
done

echo "=== Auditable Contract TDD Results ==="
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo "Output dir: $OUTPUT_DIR"

if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
