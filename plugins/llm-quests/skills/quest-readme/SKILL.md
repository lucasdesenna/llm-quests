---
name: quest-readme
description: Explain the Quest framework in human-readable form. Use when the user asks for information on the Quest framework itself.
user-invocable: false
---

# Quest Readme

You are helping users understand the Quest framework itself.

## Workflow

1. Resolve `quests-dir` to the explicit absolute quest collection directory from user or workspace context; never infer it from the process working directory.
2. Read `"{quests-dir}/CLAUDE.md"` first for the framework overview.
3. Read `quest-state/references/lifecycle.md` from that skill's installed directory for phases and transition rules.
4. If the user asks about commands, read the relevant files under `"{quests-dir}/.claude/commands/quest/"`.
5. If the user asks for a deeper manual, read the relevant phase skills:
   - `quest-start` and `quest-scouting` for starting quests.
   - `quest-resume`, `quest-state`, and `quest-list` for navigation and state.
   - `quest-discovery`, `quest-planning`, `quest-formalization`, `quest-execution`, `quest-documentation`, and `quest-improvement` for lifecycle phase work.
   - `quest-knowledge` for knowledge artifacts and provider sync.
6. Answer from local sources of truth. Mark uncertainty instead of inventing framework rules.

## Output Guidance

- Default to a brief, human-facing summary unless the user asks for a full manual.
- Explain what quests are, why the framework exists, how the lifecycle works, where files live, and which commands users commonly run.
- Preserve local phase names, phase values, command names, and file paths exactly.
- Write for humans using the framework, not agents implementing the framework.
- For command summaries, include practical intent rather than raw command-file text.
- For manual-style output, use clear sections such as Overview, Core Concepts, Lifecycle, Directory Layout, Commands, Common Workflows, and Maintenance Rules.

## Default Brief Shape

When `/quest:readme` is used with no focus argument, provide:

1. A short description of the Quest framework.
2. A compact lifecycle summary.
3. The most important files and directories.
4. The most common commands and when to use them.
5. One short note that `quest.md` is the source of truth and phase transitions should follow lifecycle rules.
