#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "$ROOT/README.md"
  "$ROOT/bundle.md"
  "$ROOT/behaviors/speedrift.yaml"
  "$ROOT/context/speedrift-protocol.md"
  "$ROOT/agents/speedrift-coordinator.md"
  "$ROOT/recipes/speedrift-start.yaml"
  "$ROOT/recipes/speedrift-task-loop.yaml"
  "$ROOT/recipes/speedrift-redrift.yaml"
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "missing: $f"; exit 1; }
done

rg -n "name:\s*speedrift" "$ROOT/bundle.md" >/dev/null
rg -n "No Beads|no-beads|Do not use Beads" "$ROOT/context/speedrift-protocol.md" >/dev/null
rg -n "\.workgraph/drifts check" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "redrift wg execute" "$ROOT/recipes/speedrift-redrift.yaml" >/dev/null

echo "smoke: ok"
