# amplifier-bundle-speedrift

Amplifier integration bundle for the Speedrift ecosystem.

This bundle makes Amplifier run in a strict Speedrift operating mode:

- Workgraph is the only task/state source of truth
- Driftdriver routes drift lanes
- Coredrift runs on every task
- No Beads workflow
- Drift checks run at task start and before task completion

## Why a Separate Repo

Yes, this should be a separate repo.

Reasons:
- independent versioning from core Speedrift lanes
- easy install/use from Amplifier (`bundle add`)
- clean ownership boundary between runtime UX (Amplifier) and governance (Speedrift)
- simpler release cadence and backward compatibility management

## Install

```bash
amplifier bundle add /absolute/path/to/amplifier-bundle-speedrift/bundle.md
# or once published
# amplifier bundle add git+https://github.com/dbmcco/amplifier-bundle-speedrift@main
```

## Use

```bash
amplifier bundle use speedrift
amplifier run "Let's get going"
```

Expected behavior:
- run start/resume protocol (`driftdriver install`, `ensure-contracts`)
- claim a ready Workgraph task
- run `./.workgraph/drifts check --task <id> --write-log --create-followups` at task start
- implement task
- run same drifts check before marking done

## Core Recipes

- `speedrift-start.yaml`: idempotent repo bootstrap/resume
- `speedrift-task-loop.yaml`: execute ready tasks with enforced pre/post checks
- `speedrift-redrift.yaml`: brownfield v2 lane via `redrift wg execute`

## Safety Rules

- Never use Beads for task-state in this mode
- Never maintain a second planner/task graph outside Workgraph
- Drift findings become `wg log` + follow-up tasks, not silent workaround code
- Prefer bounded loops and explicit phase checks for long-running lanes

## Validate Bundle Files

```bash
bash tests/smoke.sh
```

## Status

Public beta, under active development.
