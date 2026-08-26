---
name: quest-resume
description: Resume an existing quest and route the session to the correct phase. Use when the user asks to resume, continue, open, or pick up a quest by id, title, keyword, or context.
user-invocable: false
---

Use `quest-state` for resolution, validation, and lifecycle rules. Keep its explicit `quests-dir` and `quest-id`, and resolve all quest artifact paths from `"{quests-dir}/{quest-id}"`; never from the process working directory.

1. Resolve the quest:
   - With an argument, use `quest-state` to resolve it (runs `quest-resolve.sh` internally).
   - Without an argument, use the quest-list skill to show active quests and ask which to resume.
   - If id matching fails and a knowledge provider is available, search notes tagged `quest` and ask user to choose from the top results.
2. Load `"{quests-dir}/{quest-id}/quest.md"`, validate with `quest-state`'s `quest-validate.sh` using the same `quests-dir` as its first argument, and summarize title, phase, updated date, and next likely action.
3. Read the minimum extra context for the phase:
   - `discovery`: `knowledge/index.md`, relevant `knowledge/` files, and resume unknowns.
   - `planning`: all relevant `knowledge/` files.
   - `execution`: unchecked `## Execution Plan` tasks and relevant `agent-tasks/`.
   - `documentation` or `improvement`: all quest artifacts.
4. Route phase work:
   - Main session owns orchestration and final transitions.
   - Phase skills or phase agents perform bounded phase work.
5. At the end, apply any approved state changes with `quest-state`.

Legacy `phase: insights` should be treated as `phase: improvement` and normalized when editing the quest.
