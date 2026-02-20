#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "$ROOT/README.md"
  "$ROOT/bundle.md"
  "$ROOT/behaviors/speedrift.yaml"
  "$ROOT/context/speedrift-protocol.md"
  "$ROOT/context/model-routing.md"
  "$ROOT/agents/speedrift-coordinator.md"
  "$ROOT/recipes/speedrift-start.yaml"
  "$ROOT/recipes/speedrift-task-loop.yaml"
  "$ROOT/recipes/speedrift-redrift.yaml"
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "missing: $f"; exit 1; }
done

rg -n "name:\s*speedrift" "$ROOT/bundle.md" >/dev/null
rg -n "module:\s*hook-shell" "$ROOT/bundle.md" >/dev/null
rg -n "No Beads|no-beads|Do not use Beads" "$ROOT/context/speedrift-protocol.md" >/dev/null
rg -n "First-Turn Autopilot Policy|autostart hooks" "$ROOT/context/speedrift-protocol.md" >/dev/null
rg -n "model_profile" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "implementation_profile|summary_profile" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "completion_mode|complete-task|finalize-idle" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "provider_preferences|provider:" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "provider:\s*gemini|gemini-3\.1-pro|gemini-3-pro-preview" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "gemini-3\.1-pro-preview-customtools" "$ROOT/recipes/speedrift-task-loop.yaml" "$ROOT/recipes/speedrift-start.yaml" "$ROOT/recipes/speedrift-redrift.yaml" "$ROOT/context/model-routing.md" "$ROOT/README.md" >/dev/null
rg -n "\.workgraph/drifts check" "$ROOT/recipes/speedrift-task-loop.yaml" >/dev/null
rg -n "redrift wg execute" "$ROOT/recipes/speedrift-redrift.yaml" >/dev/null

echo "smoke: ok"
