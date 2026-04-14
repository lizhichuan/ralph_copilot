---
name: ralph
description: "Convert PRDs to prd.json format for Ralph. Use when you have an existing PRD and need to convert it. Triggers on: convert this prd, turn into ralph format, create prd.json from this, ralph json."
user-invocable: true
---

# Ralph PRD Converter for GitHub Copilot CLI

Converts existing PRDs to the prd.json format that Ralph uses for autonomous execution.

---

## The Job

Take a PRD (markdown file in `tasks/` or text) and convert it to `prd.json` in the **project root**.

---

## Output Format

```json
{
  "project": "[Project Name]",
  "branchName": "ralph/[feature-name-kebab-case]",
  "description": "[Feature description from PRD title/intro]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

**Important:** Save to `prd.json` in the **project root**, not in `.ralph/` directory.

---

## Story Size: The Number One Rule

**Each story must be completable in ONE Ralph iteration (one context window).**

### Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard"
- "Add authentication system"
- "Refactor the API layer"

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes
2. Backend logic
3. UI components
4. Dashboard/summary views

---

## Acceptance Criteria: Must Be Verifiable

### Good criteria (verifiable):
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Typecheck passes"

### Bad criteria (vague):
- "Works correctly"
- "Good UX"
- "Handles edge cases"

### Always include as final criterion:
```
"Typecheck passes"
```

For UI stories, also include:
```
"Verify in browser"
```

---

## Conversion Rules

1. **Each user story becomes one JSON entry**
2. **IDs**: Sequential (US-001, US-002, etc.)
3. **Priority**: Based on execution order
4. **All stories**: `passes: false` and empty `notes`
5. **branchName**: Derive from feature name, kebab-case, prefixed with `ralph/`
6. **Always add**: "Typecheck passes" to every story's acceptance criteria
7. **Output location**: `prd.json` in **project root**

---

## Checklist Before Saving

- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema → backend → UI)
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have "Verify in browser" as criterion
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] Saved to `prd.json` in project root (NOT in .ralph/)
