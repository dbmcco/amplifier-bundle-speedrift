# amplifier-bundle-speedrift

Amplifier runtime bundle for the Speedrift ecosystem.

This repo is the integration layer that makes Amplifier operate in strict, Workgraph-first Speedrift mode.

## Acknowledgements

Speedrift builds on [Workgraph](https://graphwork.github.io/) and the broader contributor ecosystem around graph-native coordination.
This bundle is separate and uses Workgraph as its execution spine.

This integration is also informed by:

- [Amplifier](https://github.com/microsoft/amplifier)
- Sam Ramparte's reference bundle patterns, including [amplifier-bundle-beads-superpowers](https://github.com/ramparte/amplifier-bundle-beads-superpowers)

## Status

`amplifier-bundle-speedrift` is in **public beta** and under active development.

- protocol and recipe defaults may evolve
- ergonomics and coverage are improving through dogfooding
- core behavior is usable now for start/resume + task execution loops

## North Star

Enable one-command agent kickoff in Amplifier without losing alignment.

That means:

- Workgraph stays the only task/state source of truth
- Speedrift drift checks run automatically at task boundaries
- findings become explicit logs/follow-ups, not hidden workaround code
- agents can run fast while intent/spec/code remain synchronized

## Why This Exists

This bundle operationalizes Speedrift goals inside Amplifier so teams can start quickly and stay aligned:

- **state discipline**: Workgraph-only task lifecycle
- **drift discipline**: pre/post task checks with `./.workgraph/drifts check`
- **loop discipline**: bounded redirect behavior via existing Speedrift policy
- **brownfield discipline**: explicit handoff to `redrift` v2 lane workflows

## What This Bundle Does

When active, the bundle biases execution toward this flow:

1. Start/resume with wrapper and contract bootstrap
2. Claim ready Workgraph task
3. Run pre-check drift telemetry
4. Implement task work
5. Run post-check drift telemetry
6. Convert uncertainty into follow-up tasks instead of in-place drift

## Autostart With Workgraph

This bundle includes shell-hook support (`hook-shell`) and can run with repo-level autostart hooks.

Recommended repo wiring (from your project root):

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor
```

That writes:

- `.workgraph/executors/amplifier.toml` + `.workgraph/executors/amplifier-run.sh`
- `.amplifier/hooks/speedrift-autostart/hooks.json`
- `.amplifier/hooks/speedrift-autostart/session-start.sh`

Effect:

- Workgraph can spawn Amplifier executor sessions
- Amplifier autostart hooks auto-check Workgraph/Speedrift bootstrap state at session start and first prompt submit

## Mental Model

- **Track**: Workgraph graph (`wg`) for tasks/dependencies/loops
- **Pit wall**: `driftdriver` wrapper + policy routing
- **Telemetry**: `coredrift` baseline + optional drift lanes
- **Countersteer**: `wg log` and follow-up tasks
- **Pit stop**: `redrift` phased lanes for v1 -> v2 rebuild programs

## Model-Mediated Approach

This bundle follows the same Speedrift split:

- **pipes execute**: lane CLIs gather evidence and emit deterministic outputs
- **models decide**: Amplifier agents interpret evidence and choose next actions
- **graph records intent**: contracts/fences/logs live in Workgraph artifacts
- **follow-ups over hidden fixes**: uncertain work is externalized to tasks

## Technical Escalation Policy

Default posture is "research first, ask last":

- resolve technical parameters from local evidence before asking (task context, repo config, running services)
- if user intent is clear but one technical value is missing, infer and proceed
- ask the user only for judgment-level choices (priority, aesthetics, policy/risk) or missing credentials
- when a question is required, provide one concise question with a recommended default and evidence

## Model Routing Profiles

This bundle supports profile-driven model routing inside recipes:

- `balanced`: default feature/fix workflow
- `quality`: deeper reasoning (recommended for complex/redrift work)
- `cost`: cheaper models for routine loops and summaries
- `local`: prefer local models first, then cloud fallback

Stage overrides are supported so different Speedrift parts can use different models:

- `model_profile`: root/default profile
- `implementation_profile`: implementation stage override (`speedrift-task-loop.yaml`)
- `summary_profile`: summary/analysis stage override

Default stage behavior:

- implementation uses `model_profile` unless `implementation_profile` is set
- summaries default to `cost` for most flows
- summaries default to `balanced` when `model_profile=quality`
- summaries default to `local` when `model_profile=local`

Provider preferences include Anthropic, OpenAI, Ollama (local profile), and Google Gemini (`gemini-3.1-pro-preview-customtools*` preferred for tool-heavy loops, then `gemini-3.1-pro-preview*`, then `gemini-3-pro-preview*`).

The profile does not change Speedrift policy:

- Workgraph remains the source of truth
- pre/post `./.workgraph/drifts check` still runs
- findings still become `wg log` + follow-up tasks

## Architecture

```text
Amplifier Session (speedrift bundle)
  -> recipes + coordinator behavior
  -> Workgraph task lifecycle (ready/claim/done)
  -> driftdriver wrappers under .workgraph/
  -> coredrift always, optional lanes by strategy/fences
  -> wg log + follow-up creation
```

## Prerequisites

At minimum:

- `wg` (Workgraph CLI)
- `driftdriver` + desired Speedrift lanes installed (typically via `pipx`)
- `amplifier` installed and configured
- `git`

Typical lane install set:

```bash
pipx install git+https://github.com/dbmcco/driftdriver.git
pipx install git+https://github.com/dbmcco/coredrift.git
pipx install git+https://github.com/dbmcco/specdrift.git
pipx install git+https://github.com/dbmcco/datadrift.git
pipx install git+https://github.com/dbmcco/archdrift.git
pipx install git+https://github.com/dbmcco/depsdrift.git
pipx install git+https://github.com/dbmcco/uxdrift.git
pipx install git+https://github.com/dbmcco/therapydrift.git
pipx install git+https://github.com/dbmcco/yagnidrift.git
pipx install git+https://github.com/dbmcco/redrift.git
```

## Installation

From local checkout:

```bash
amplifier bundle add /absolute/path/to/amplifier-bundle-speedrift/bundle.md
amplifier bundle use speedrift
```

From GitHub:

```bash
amplifier bundle add git+https://github.com/dbmcco/amplifier-bundle-speedrift@main
amplifier bundle use speedrift
```

## Usage Process

### 1) Start In Minutes (New Or Existing Repo)

If no Workgraph yet:

```bash
wg init
```

Install/refresh Speedrift wrappers and contracts:

```bash
./.workgraph/driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor \
  || ./.workgraph/driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
```

If `./.workgraph/driftdriver` is missing, use:

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor \
  || driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
```

### 2) Run The Day-To-Day Task Loop

Kickoff autopilot:

```bash
amplifier "Let's get started. Use speedrift and workgraph. Do not ask for scope; claim the first ready task and execute."
```

Explicit single-task pass:

```bash
amplifier "Claim task my-task-id, run pre/post ./.workgraph/drifts check, implement, and mark done/submit."
```

Direct CLI loop (deterministic fallback):

```bash
TASK_ID=$(wg ready --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d[0]["id"] if d else ""))')
wg claim "$TASK_ID"
./.workgraph/drifts check --task "$TASK_ID" --lane-strategy auto --write-log --create-followups
# implement task work
./.workgraph/drifts check --task "$TASK_ID" --lane-strategy auto --write-log --create-followups
wg done "$TASK_ID"
```

Low-cost routine pass:

```bash
amplifier "Use cost profile behavior for task my-task-id. Run full pre/post drift loop and complete if clean."
```

Prefer local models:

```bash
amplifier "Use local profile behavior for task my-task-id. Run full pre/post drift loop and complete if clean."
```

### 3) Brownfield Rebuilds (v1 -> v2)

Launch phased redrift lane:

```bash
./.workgraph/redrift wg execute --task redrift-app-v2 --write-log --phase-checks
```

With explicit v2 target path:

```bash
./.workgraph/redrift wg execute --task redrift-app-v2 --write-log --phase-checks
```

Set the v2 path in the task's `redrift` block/fence before execution.

Recommended per-phase closeout:

```bash
./.workgraph/redrift wg verify --task redrift-exec-<phase>-<root_id> --write-log
./.workgraph/drifts check --task redrift-exec-<phase>-<root_id> --write-log --create-followups
./.workgraph/redrift wg commit --task redrift-exec-<phase>-<root_id> --phase <phase>
```

### 4) Optional Continuous Pit-Wall Mode

```bash
./.workgraph/drifts orchestrate --write-log --create-followups
```

### 4b) Zero-Friction Start Pattern

With the global bundle set to `speedrift` and autostart hooks installed in the repo:

```bash
amplifier
```

Then a simple prompt like "get started and use speedrift with workgraph" should:

1. bootstrap/resume wrappers and contracts
2. execute task-loop passes until the queue idles
3. externalize drift findings as logs/follow-ups

### 5) Provider/Model Overrides At Runtime

Use Amplifier provider switching for global/session-level defaults:

```bash
amplifier provider use anthropic --model claude-sonnet-*
amplifier provider use openai --model gpt-5*
amplifier provider use gemini --model gemini-3.1-pro-preview-customtools
amplifier provider use ollama --model qwen2.5-coder
```

Use one-off run overrides when needed:

```bash
amplifier run --provider openai --model gpt-5.2 "Reply with current provider/model and confirm tool-use readiness."
amplifier run --provider gemini --model gemini-3.1-pro-preview-customtools "Reply with current provider/model and confirm tool-use readiness."
```

Use stage-specific profile overrides when needed:

```bash
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task-id' model_profile='quality' summary_profile='cost'"
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task-id' model_profile='balanced' implementation_profile='quality' summary_profile='cost'"
```

Task closure mode (`speedrift-task-loop.yaml`):

- `completion_mode='suggest'` (default): recipe summarizes next command and leaves closure to operator.
- `completion_mode='auto'`: recipe attempts deterministic closure (`wg done`, or `wg submit` when verification is required).

If a session keeps "planning" instead of executing:

```bash
amplifier tool invoke recipes \
  operation=execute \
  recipe_path=/Users/braydon/projects/experiments/amplifier-bundle-speedrift/recipes/speedrift-task-loop.yaml \
  context='{"model_profile":"balanced","summary_profile":"cost","completion_mode":"auto"}'
```

This bypasses conversational planning and runs one deterministic task-loop pass directly.

## Recipe Assets

| Recipe | Purpose | Typical Use |
|---|---|---|
| `speedrift-start.yaml` | idempotent install/resume bootstrap | start of session/project |
| `speedrift-task-loop.yaml` | claim + precheck + implement + postcheck | normal feature/fix loop |
| `speedrift-redrift.yaml` | launch redrift phased lane | brownfield v2 programs |

Note: these files are maintained in this bundle repo; do not rely on `recipes execute` path lookup in arbitrary app repos unless you have explicitly mounted those recipe files into the runtime.

## Kickoff Prompts

Recommended natural-language kickoff:

- `Let's get going. Use speedrift and amplifier, no beads.`
- `Use Workgraph as source of truth, run speedrift checks at task start and before done.`

Expected behavior:

- bootstrap/resume wrappers
- operate through `wg ready` / `wg claim`
- run `./.workgraph/drifts check --task <id> --write-log --create-followups` pre and post task

## Safety Rules

- Never use Beads for task-state unless user explicitly asks for it.
- Never maintain a second planner/ledger outside Workgraph.
- Drift findings become `wg log` and follow-up tasks.
- Prefer bounded recursion and explicit phase gates on long lanes.

## Fallback (Without Recipes)

If recipe execution is unavailable, use direct Speedrift commands:

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor \
  || driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

## Repo Layout

```text
amplifier-bundle-speedrift/
  bundle.md
  behaviors/speedrift.yaml
  context/speedrift-protocol.md
  context/model-routing.md
  agents/speedrift-coordinator.md
  recipes/
    speedrift-start.yaml
    speedrift-task-loop.yaml
    speedrift-redrift.yaml
  tests/smoke.sh
```

## Validation

Run local bundle smoke checks:

```bash
bash tests/smoke.sh
```

## Known Limitations

- Depends on external lane CLIs being installed and on PATH.
- Recipe behavior is only as deterministic as underlying executor/tool availability.
- Public beta: conventions and defaults may evolve quickly.

## Why This Is A Separate Repo

Separation is intentional:

- independent versioning from core Speedrift lanes
- clean ownership boundary: runtime integration vs governance engines
- easier adoption for Amplifier users without modifying lane repos
- simpler release/testing cadence

## Related Repos

- Speedrift suite home: https://github.com/dbmcco/speedrift-ecosystem
- Orchestrator: https://github.com/dbmcco/driftdriver
- Baseline lane: https://github.com/dbmcco/coredrift
- Brownfield lane: https://github.com/dbmcco/redrift
- Amplifier: https://github.com/microsoft/amplifier
- Sam Ramparte tutorial: https://github.com/ramparte/amplifier-tutorial
- Sam Ramparte Workgraph bundle: https://github.com/ramparte/amplifier-bundle-workgraph
- Sam Ramparte reference: https://github.com/ramparte/amplifier-bundle-beads-superpowers

## License

MIT. See `LICENSE` (or inherit from ecosystem policy until copied here).
