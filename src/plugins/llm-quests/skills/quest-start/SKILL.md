---
name: quest-start
description: Start a new throughly defined Quest by scaffolding files and setting its initial state. Use when the user asks for a new Quest and is able to provide `quest-id`, `title` and `problem-definition`.
user-invocable: false
---

1. Resolve `quests-dir` to the absolute path of the quest collection directory, whose direct children are quest ids. Get it from explicit user or workspace context; never derive it from the process working directory. If it cannot be determined, ask the user.
2. Capture proposed title and quest id. Confirm them with user.
3. Resolve the scaffold script from this skill's installed directory and run `bash "<current-skill-dir>/scripts/quest-scaffold.sh" "/absolute/path/to/quests" <quest-id> <title> <problem-definition>`. Do not use a working-directory-relative script path.
4. Use `quest-state` with the same `quests-dir` for validation and `quest-knowledge` for knowledge provider sync.
