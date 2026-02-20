# Speedrift Model Routing

Speedrift uses one bundle and routes model quality/cost by profile and stage.

## Profiles

- `balanced`: default for day-to-day feature/fix loops.
- `quality`: deeper reasoning for spec-heavy or redrift tasks.
- `cost`: lower-cost model path for routine checks and summaries.
- `local`: prefer local models first (for privacy/offline/cost control).

## Stage Overrides

Recipes support stage-specific routing so different parts of the same flow can use different models:

- `model_profile`: root/default profile.
- `implementation_profile`: overrides implementation stage (task-loop only).
- `summary_profile`: overrides summary/analysis stages.

If stage overrides are omitted:

- implementation defaults to `model_profile`
- summaries default to `cost` for most flows
- summaries default to `balanced` when `model_profile=quality`
- summaries default to `local` when `model_profile=local`

## Routing Intent

- Task planning + synthesis: quality-weighted models.
- Implementation loops: balanced models.
- Verification/summaries: cost-aware models.
- Rebuild (`redrift`) programs: quality profile by default.

## Selection Rules

1. Use `model_profile` recipe context when running Speedrift recipes.
2. Use stage overrides when you want different models for implementation vs summary.
3. Keep Workgraph + drift checks invariant across all profiles.
4. Do not maintain separate behavior rules per provider.

## Provider Coverage

Default provider preferences now include:

- Anthropic
- OpenAI
- Google Gemini (`gemini-3.1-pro-preview-customtools*` preferred for tool-heavy loops, then `gemini-3.1-pro-preview*`, then `gemini-3-pro-preview*`)
- Ollama (for `local` profile first-pass routing)

## Example

```bash
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='balanced'"
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='quality'"
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='quality' summary_profile='cost'"
amplifier run "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='balanced' implementation_profile='quality' summary_profile='cost'"
```

Provider can still be overridden per run when needed:

```bash
amplifier run --provider openai "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='cost'"
amplifier run --provider gemini --model gemini-3.1-pro-preview-customtools "execute speedrift-task-loop.yaml with task_id='my-task' model_profile='quality'"
```
