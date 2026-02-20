# Speedrift Protocol (No-Beads)

You are operating in Speedrift mode.

## Invariants

1. Workgraph is the only task graph and source of task truth.
2. Do not use Beads or any second task ledger.
3. Run Speedrift checks at task start and before task completion.
4. Findings must be externalized to Workgraph (`wg log`, follow-up tasks).
5. Do not use `wg status` (not supported); use `wg ready`, `wg coordinate`, `wg show <id>`, `wg list`.

## Research-First, Ask-Last Policy

Treat technical detail resolution as implementer work, not user burden.

Before asking a clarifying question, inspect:

- current Workgraph task context (`wg show <id> --json`)
- repository defaults/config and prior implementation patterns
- local runtime state (for example `ollama ps`, `ollama list`)

When user intent is clear but one parameter is missing (for example provider specified but model unspecified), infer from local evidence and proceed.

Escalate only when the choice is genuinely user-owned:

- product/judgment calls (priority, aesthetics, direction)
- governance/risk acceptance
- missing credentials/secrets or hard environment blockers

If escalation is required, ask one concise question with a recommended default and brief evidence.

## Start/Resume Protocol

From repo root:

```bash
if [ -x "./.workgraph/driftdriver" ]; then
  ./.workgraph/driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor \
    || ./.workgraph/driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
else
  driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift --with-amplifier-executor \
    || driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
fi
./.workgraph/coredrift ensure-contracts --apply
```

If no graph exists yet:

```bash
wg init
```

## First-Turn Autopilot Policy

When the user asks to start work (for example: "let's get started", "use speedrift", "run workgraph"), do this by default:

1. bootstrap directly via shell commands (do not rely on recipe lookup):
   - install wrappers with executor support when available, and auto-fallback when `--with-amplifier-executor` is unsupported:
     - wrapper path: `./.workgraph/driftdriver install ... --with-amplifier-executor || ./.workgraph/driftdriver install ...`
     - global path: `driftdriver install ... --with-amplifier-executor || driftdriver install ...`
   - `./.workgraph/coredrift ensure-contracts --apply`
2. claim and execute the first ready task automatically:
   - `TASK_ID=$(wg ready --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d[0]["id"] if d else ""))')`
   - if non-empty: run precheck, implement, postcheck, `wg done`/`wg submit`
3. continue a bounded loop (default cap: 3 tasks per turn), then report progress
4. execute-first requirement: run at least one real tool command before any narrative summary on kickoff prompts
5. do not call planner/delegate agents on kickoff; operate directly with shell/workgraph commands unless user explicitly requests delegation
6. do not ask for discoverable technical defaults during kickoff (for example "which Ollama embedding model?"); inspect local context first and choose the most established default

Kickoff termination rules (mandatory):

- If `wg ready --json` returns no task (`[]`), stop after one pass and return an idle status.
- Optional: run exactly one `wg list --json` read to report top blockers; do not loop/retry repeatedly.
- Do not keep "planning" once no task is claimable; return control to the user with one next-step command.
- Do not call `wg status`; it is unsupported.

If `.amplifier/hooks/speedrift-autostart/hooks.json` exists in the project, autostart hooks should pre-bootstrap Workgraph/Speedrift before (or at) the first prompt.
Do not ask the user to choose scope/task on kickoff unless blocked by missing credentials, missing tooling, or a hard policy conflict.
Do not mutate the graph shape on kickoff (`wg add`, `wg abandon`, bulk task decomposition) unless the user explicitly requests decomposition/refactor.

## Per-Task Protocol

For each claimed task:

```bash
./.workgraph/drifts check --task <task_id> --write-log --create-followups
# implement task work
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

Execution evidence requirements:

- Add at least one `wg log <task_id> ...` entry capturing what changed and why.
- If concrete file outputs are known, record them with `wg artifact <task_id> <path>`.
- End claimed tasks in a terminal state: `wg done`, `wg submit` (for verified tasks), or `wg fail` with explicit reason.

## UX Decision Guardrails

When task work touches frontend/UI/UX:

- Preserve existing design system and product language by default (tokens, component patterns, spacing rhythm, interaction patterns).
- Do not perform broad visual redesign unless the task explicitly asks for a redesign.
- Scope UX edits to acceptance criteria; avoid opportunistic style refactors in non-UX tasks.
- Base UX decisions on local evidence (existing UI patterns, task context, issue reports, captured evidence); avoid subjective style pivots.
- If there are multiple valid UX options and product direction is ambiguous, ask one concise question with a recommended default.

When task is explicitly UX-heavy, prefer full drift coverage:

```bash
./.workgraph/drifts check --task <task_id> --lane-strategy all --write-log --create-followups
```

When pre-check reports yellow/red due budget or scope pressure:

- log findings with `wg log <task_id> ...`
- do not auto-decompose or bulk-create tasks unless user explicitly requested it
- either continue within scope, or unclaim and move to next ready task if blocked

For complex/rebuild tasks:

```bash
./.workgraph/drifts check --task <task_id> --lane-strategy all --write-log --create-followups
```

Use model profiles to match cost/quality while preserving the same Workgraph + drift loop:

- `balanced`: default feature/fix loop
- `quality`: complex/rebuild/root-cause-heavy work
- `cost`: routine drift passes and summaries
- `local`: prefer local models first, cloud fallback if needed

## Brownfield Rebuild Protocol

When task clearly indicates v1 -> v2 rebuild:

```bash
./.workgraph/redrift wg execute --task <root_task_id> --write-log --phase-checks
```

## Completion Rules

- No silent workaround code for drift findings.
- Use follow-up tasks for uncertain, out-of-scope, or high-risk changes.
- Mark task done only after pre/post drifts checks are complete.
- If task uses verification, use `wg submit` instead of `wg done`.
