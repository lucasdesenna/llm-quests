---
name: quest-knowledge
description: Manage quest-local knowledge artifacts and configured provider sync. Use for knowledge status, provider sync, search, export, and federation-oriented workflows.
user-invocable: false
---

# Quest Knowledge

Use this skill when a command or phase needs to inspect, sync, search, or export quest knowledge. Use `quest-state` first when a quest id must be resolved or lifecycle state is relevant. Keep its explicit `quests-dir` and `quest-id`, and resolve quest-local paths from `"{quests-dir}/{quest-id}"`; never from the process working directory.

## Local Contract

- `quest.md` is authoritative for lifecycle state.
- `knowledge/` is authoritative for curated quest knowledge artifacts.
- `knowledge/index.md` catalogs important artifacts, their type, status, and provider sync intent.
- Providers are derived search, link, index, or federation layers.
- basic-memory is the default provider when configured, but workflows must remain provider-neutral.

## Artifact Types

- `knowledge/sources/`: source summaries, links, excerpts, or raw input pointers.
- `knowledge/findings/`: source-backed claims and implications.
- `knowledge/decisions/`: durable choices, rationale, and rejected options.
- `knowledge/patterns/`: reusable lessons or cross-quest abstractions.
- `knowledge/summaries/`: phase or topic summaries that should remain with the quest.

## Workflow

1. Resolve the quest with `quest-state` when needed.
2. Read `knowledge/index.md` before inspecting individual artifacts.
3. For status, report missing index entries, stale `updated` dates, and provider sync values.
4. For sync, follow `/quest:knowledge` and `commands/quest/knowledge.md`.
5. For search, prefer the configured provider. If none is available, fall back to local file search under `"{quests-dir}/"`.
6. For export, include stable quest identity plus provider-ready knowledge artifacts. Exclude execution progress and Jira status as state.

## Provider Sync Values

- `skip`: do not index this artifact.
- `pending`: index or refresh this artifact on the next sync.
- `indexed`: provider is expected to have a current copy.
- `stale`: local artifact changed after provider indexing.
