---
name: quest-execution
description: Orchestrate quest execution tasks. Use during Execution to create task briefs, dispatch bounded subagents, track progress, handle blockers, and report completion.
user-invocable: false
---

Use `quest-state` first. Keep its explicit `quests-dir` and `quest-id`, and resolve all quest artifact paths from `"{quests-dir}/{quest-id}"`; never from the process working directory. Execution carries out the plan; the main session still owns final phase transition.

1. Read `## Execution Plan` and identify the next unchecked task or independent batch.
2. For complex or parallel work, write standalone briefs under `"{quests-dir}/{quest-id}/agent-tasks/"` before dispatch.
3. Spawn bounded subagents for independent tasks. Use code explorers for read-only investigation, implementation agents for code changes, and reviewers for PR/diff review.
4. Review each result before checking off tasks.
5. If a new unknown appears, record it and run focused Discovery work instead of guessing.
6. Update Jira statuses only when cards exist and the state change is clear.
7. Report tasks completed, remaining work, blockers, and PR links.

Use `references/task-brief-template.md`.
