---
name: quest-improvement
description: Reflect on a completed quest and produce a concrete methodology improvement plan. Use during the Improvement phase, formerly Insights, to record friction and propose skill/script/template changes without applying them immediately.
user-invocable: false
---

Use `quest-state` first. Keep its explicit `quests-dir` and `quest-id`, and resolve all quest artifact paths from `"{quests-dir}/{quest-id}"`; never from the process working directory. Improvement records concrete process learning and proposes follow-up edits; it does not directly modify skills or methodology files.

1. Read `quest.md`, `knowledge/index.md`, relevant knowledge artifacts, `summary.md`, and task briefs from `"{quests-dir}/{quest-id}"`.
2. Identify concrete friction from this quest: stalls, missing context, weak tools, wasteful phase work, or repeated patterns.
3. Separate observations from recommendations.
4. Propose edits to existing skills before proposing new skills.
5. Propose a new skill only when the quest showed a repeated pattern likely to recur.
6. Write `## Improvement` in `"{quests-dir}/{quest-id}/quest.md"` with observations, recommendations, and a small implementation plan.
7. Report whether the quest can be marked `complete`.

Use `references/improvement-template.md`.
