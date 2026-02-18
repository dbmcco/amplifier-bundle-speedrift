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

Run bundle bootstrap recipe:

```bash
amplifier run "execute speedrift-start.yaml"
```

This performs:

- `driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift`
- `./.workgraph/coredrift ensure-contracts --apply`

### 2) Run The Day-To-Day Task Loop

One pass:

```bash
amplifier run "execute speedrift-task-loop.yaml"
```

Explicit task:

```bash
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task-id'"
```

Force full-suite lane strategy on hard tasks:

```bash
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task-id' lane_strategy='all'"
```

### 3) Brownfield Rebuilds (v1 -> v2)

Launch phased redrift lane:

```bash
amplifier run "execute speedrift-redrift.yaml with root_task_id='redrift-app-v2'"
```

With explicit v2 target path:

```bash
amplifier run "execute speedrift-redrift.yaml with root_task_id='redrift-app-v2' v2_repo='/path/to/app-v2'"
```

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

## Recipe Reference

| Recipe | Purpose | Typical Use |
|---|---|---|
| `speedrift-start.yaml` | idempotent install/resume bootstrap | start of session/project |
| `speedrift-task-loop.yaml` | claim + precheck + implement + postcheck | normal feature/fix loop |
| `speedrift-redrift.yaml` | launch redrift phased lane | brownfield v2 programs |

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
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

## Repo Layout

```text
amplifier-bundle-speedrift/
  bundle.md
  behaviors/speedrift.yaml
  context/speedrift-protocol.md
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
- Sam Ramparte reference: https://github.com/ramparte/amplifier-bundle-beads-superpowers

## License

MIT. See `LICENSE` (or inherit from ecosystem policy until copied here).
