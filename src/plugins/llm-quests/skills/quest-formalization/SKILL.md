---
name: quest-formalization
description: Draft and create Jira cards from an approved quest execution plan. Use during Formalization when team-visible Jira work is needed.
user-invocable: false
---

Use `quest-state` first. Keep its explicit `quests-dir` and `quest-id`, and resolve all quest artifact paths from `"{quests-dir}/{quest-id}"`; never from the process working directory. Never create or update Jira cards without explicit user approval.

1. Read the approved `## Execution Plan` and relevant knowledge artifacts.
2. Draft Jira cards with summary, background, acceptance criteria, context links, dependencies, and out-of-scope notes.
3. Present all drafts in one review pass.
4. After approval, create cards via Atlassian MCP and link dependencies as needed.
5. Update `## Jira Cards` in `"{quests-dir}/{quest-id}/quest.md"` and annotate execution tasks with card keys.
6. Report created card keys and whether the main session can transition to Execution.

Use `references/jira-card-template.md`.
