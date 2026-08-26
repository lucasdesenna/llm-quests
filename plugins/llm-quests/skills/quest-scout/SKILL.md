---
name: quest-scouting
description: Interview user on a Quest idea until it can be formalized. Use when user expresses the intention of creating a new Quest but can't define it.
user-invocable: false
---

1. Resolve `quests-dir` to the explicit absolute quest collection path through `quest-start`; never infer it from the process working directory.
2. Analyze provided information. Fetch external artifacts when supplied – eg. Jira cards, Slack messages, Google documents and Confluence pages.
3. Interview me relentlessly about the Quest idea until you can infer all the arguments of `quest-start`. Consider topics such as:
   - Desired outcome
   - Stakeholders
   - Scope
   - Urgency
   - Known facts
   - Unknowns
   - Constraints
4. Once I approve the inferred arguments, invoke `quest-start` with them and the resolved `quests-dir`.
