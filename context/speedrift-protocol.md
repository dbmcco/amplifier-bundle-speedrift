# Speedrift Protocol (No-Beads)

You are operating in Speedrift mode.

## Invariants

1. Workgraph is the only task graph and source of task truth.
2. Do not use Beads or any second task ledger.
3. Run Speedrift checks at task start and before task completion.
4. Findings must be externalized to Workgraph (`wg log`, follow-up tasks).

## Start/Resume Protocol

From repo root:

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
```

If no graph exists yet:

```bash
wg init
```

## Per-Task Protocol

For each claimed task:

```bash
./.workgraph/drifts check --task <task_id> --write-log --create-followups
# implement task work
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

For complex/rebuild tasks:

```bash
./.workgraph/drifts check --task <task_id> --lane-strategy all --write-log --create-followups
```

## Brownfield Rebuild Protocol

When task clearly indicates v1 -> v2 rebuild:

```bash
./.workgraph/redrift wg execute --task <root_task_id> --write-log --phase-checks
```

## Completion Rules

- No silent workaround code for drift findings.
- Use follow-up tasks for uncertain, out-of-scope, or high-risk changes.
- Mark task done only after pre/post drifts checks are complete.
