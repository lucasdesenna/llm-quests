---
name: quest-state
description: Resolve, load, validate, update, and transition quest state. Use for any quest command or phase handoff that reads quest.md, changes phase/updated frontmatter, or validates lifecycle rules.
user-invocable: false
---

# Quest State

This skill owns quest identity and lifecycle state. Use it before phase work and again before final state changes.

## Workflow

1. Resolve `quests-dir` to the absolute path of the quest collection directory, whose direct children are quest ids. Get it from explicit user or workspace context; never derive it from the process working directory. If it cannot be determined, ask the user. Keep this value unchanged through delegated phase work.
2. Resolve each script path from its owning skill's installed directory; never use a working-directory-relative `scripts/...` path.
3. Resolve a quest id with `bash "<current-skill-dir>/scripts/quest-resolve.sh" "/absolute/path/to/quests" <query>`. If no query was provided, run the quest-list skill with the same `quests-dir`. If script resolution is ambiguous, show the candidates and stop.
4. Set `quest-id` from the resolved row and load `"{quests-dir}/{quest-id}/quest.md"`. Read frontmatter first, then the relevant body sections for the current phase.
5. Validate structure with `bash "<current-skill-dir>/scripts/quest-validate.sh" "{quests-dir}" "{quest-id}"` before acting on the quest.
6. Route phase work to the appropriate phase skill or agent, passing the resolved `quests-dir` and `quest-id` explicitly:
   - `scouting` -> `quest-scouting`
   - `discovery` -> `quest-discovery`
   - `planning` -> `quest-planning`
   - `formalization` -> `quest-formalization`
   - `execution` -> `quest-execution`
   - `documentation` -> `quest-documentation`
   - `improvement` -> `quest-improvement`
7. Apply final phase transitions only from the main session after reviewing phase output. Check `references/lifecycle.md`, then run `bash "<current-skill-dir>/scripts/quest-transition.sh" <from> <to>` for forward transitions.
8. When changing the quest body or phase, bump `updated:` to today's `YYYY-MM-DD`.

## State Contract

- `quest.md` is the source of truth.
- `quests-dir` is always an explicit absolute path to the quest collection directory. Pass it as the first argument to every script that reads or writes quests; never default it from `cwd` or an environment variable.
- `quest-id` is the selected quest's directory name, so its absolute directory is `"{quests-dir}/{quest-id}"`.
- Subagents may produce phase artifacts, but the main session owns phase transitions and final frontmatter updates.
- Do not skip phases unless user explicitly directs it or the skip is recorded with a reason in `quest.md`.

See `references/lifecycle.md` for phases and exit criteria.
