---
name: ralph-run
description: "Run the Ralph autonomous agent loop inside Copilot CLI. Executes user stories from prd.json one by one until all are complete. Use when asked to run ralph, execute prd stories, or work autonomously on multiple tasks."
user-invocable: true
---

# Ralph Autonomous Agent Loop for Copilot CLI

Run Ralph directly inside Copilot CLI - no bash script needed. Executes user stories from `prd.json` autonomously.

---

## The Job

1. Read `prd.json` to get the list of user stories
2. Read `progress.txt` for context and learned patterns
3. Pick the highest priority story where `passes: false`
4. Implement that ONE story
5. Run quality checks (typecheck, lint, test)
6. Commit if checks pass
7. Update `prd.json` to mark story as `passes: true`
8. Append progress to `progress.txt`
9. Check if more stories remain
10. If more stories exist, continue to next iteration
11. If all stories complete, signal completion

---

## How to Use

### Start Ralph in Copilot CLI

```bash
cd /path/to/your/project
copilot --experimental  # Enable experimental mode for Autopilot
```

Then say:

```
Load the ralph-run skill and execute all pending stories in prd.json
```

Or:

```
Run Ralph on prd.json - implement all stories where passes is false
```

### With Autopilot Mode

After loading Copilot CLI:
1. Press `Shift+Tab` to cycle to **Autopilot** mode
2. Give the initial prompt above
3. Ralph will work autonomously until all stories are complete

---

## Before You Start

### 1. Verify prd.json exists

```
Check if prd.json exists in the current directory
```

Required format:
```json
{
  "project": "MyApp",
  "branchName": "ralph/feature-name",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Story title",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": ["Criterion 1", "Typecheck passes"],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### 2. Verify progress.txt exists

```
Check if progress.txt exists in the current directory
```

If not, create it:
```markdown
# Ralph Progress Log

Started: [today's date]

---

## Codebase Patterns

[Add patterns here as you discover them]

---

## Iteration Log

```

### 3. Ensure correct branch

```
Read prd.json and check if we're on the correct branch from branchName
```

If not:
```bash
git checkout -b ralph/feature-name  # Create if doesn't exist
# or
git checkout ralph/feature-name     # Switch if exists
```

---

## Each Iteration

### Step 1: Read Context

```
1. Read prd.json and find the highest priority story where passes == false
2. Read progress.txt, especially the "Codebase Patterns" section
3. Note the story ID, title, description, and acceptance criteria
```

### Step 2: Implement the Story

Work on ONLY this one story. Do not start the next story.

```
Implement [Story ID]: [Story Title]
- Follow the acceptance criteria exactly
- Follow existing code patterns in the project
- Keep changes minimal and focused
```

### Step 3: Run Quality Checks

```
Run the project's quality checks:
- Typecheck: npm run typecheck, npx tsc --noEmit, or equivalent
- Lint: npm run lint or equivalent
- Test: npm test or equivalent
```

If checks fail, fix the issues before proceeding.

### Step 4: Update AGENTS.md (if applicable)

If you discovered reusable patterns, add them to AGENTS.md in the relevant directory:

```markdown
## Patterns

- [Pattern you discovered]
```

### Step 5: Commit

```bash
git add -A
git commit -m "feat: [Story ID] - [Story Title]"
```

### Step 6: Update prd.json

Set `passes: true` for the completed story:

```
Update prd.json to set passes: true for story [Story ID]
```

Or use jq:
```bash
jq '.userStories = [.userStories[] | if .id == "US-001" then .passes = true else . end]' prd.json > prd.json.tmp && mv prd.json.tmp prd.json
```

### Step 7: Update progress.txt

APPEND to progress.txt (never replace):

```markdown
## [Date/Time] - [Story ID]

### What was implemented
- [Brief description]

### Files changed
- `path/to/file1.ts`
- `path/to/file2.ts`

### Learnings for future iterations
- [Pattern discovered]
- [Gotcha encountered]
- [Useful context]

---
```

### Step 8: Check Completion

```
Read prd.json and check if all stories have passes == true
```

**If ALL stories are complete:**
```
<promise>COMPLETE</promise>

All user stories completed!
- Total stories: [count]
- Completed in [N] iterations
- Branch: [branchName]
```

**If stories remain:**
```
Continue to next story: [Next Story ID] - [Next Title]
```

---

## Story Size Rules

**Right-sized stories (good):**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

**Too big (should be split in prd.json):**
- "Build the entire dashboard"
- "Add authentication system"
- "Refactor the API layer"

If a story is too big, note it in progress.txt and suggest splitting.

---

## Acceptance Criteria Rules

Every story must have verifiable criteria:

**Good:**
- "Add `priority` column to tasks table"
- "Filter dropdown has options: All, High, Medium, Low"
- "Typecheck passes"

**Bad:**
- "Works correctly"
- "Good UX"
- "Handles edge cases"

**Always include:**
- "Typecheck passes"
- "Verify in browser" (for UI changes)

---

## Example Session

```
User: Load the ralph-run skill and execute all pending stories in prd.json

Ralph: I'll run Ralph on your prd.json. Let me start by reading the context.

[Reads prd.json and progress.txt]

Found 4 pending stories. Starting with US-001: Add priority field to database.

[Implements the story]
[Runs typecheck - passes]
[Commits: "feat: US-001 - Add priority field to database"]
[Updates prd.json: US-001 passes = true]
[Appends to progress.txt]

Continuing to US-002: Display priority indicator on task cards.

[Continues until all stories complete]

<promise>COMPLETE</promise>

All user stories completed!
- Total stories: 4
- Completed in 4 iterations
- Branch: ralph/task-priority
```

---

## Stop Conditions

Stop and report to user if:

1. **All stories complete** - Signal with `<promise>COMPLETE</promise>`
2. **Quality checks fail repeatedly** - Report the issue
3. **Story is too big** - Suggest splitting
4. **Missing dependencies** - Report what's needed
5. **User interrupts** - Save progress and report state

---

## Tips for Success

1. **One story per iteration** - Never combine stories
2. **Read progress.txt first** - Learn from previous iterations
3. **Update AGENTS.md** - Preserve discovered patterns
4. **Keep CI green** - Never commit broken code
5. **Small commits** - One commit per story
6. **Verify in browser** - For UI changes, visually confirm

---

## Troubleshooting

### prd.json not found
```
Error: prd.json not found in current directory.

Please create a prd.json file with your user stories.
Use the prd skill to generate one, or see prd.json.example for format.
```

### All stories already complete
```
All stories in prd.json are already marked as passes: true.

Ralph has nothing to do! 🎉

To start a new feature:
1. Update prd.json with new stories
2. Or create a new prd.json for a different feature
```

### Branch mismatch
```
Warning: Current branch is 'main' but prd.json specifies 'ralph/feature-name'.

Switching to correct branch...
```

### Quality checks failing
```
Quality checks failed:
- Typecheck: 3 errors in src/components/TaskCard.tsx

Fixing issues before committing...
```

---

## Checklist

Before running Ralph:

- [ ] prd.json exists with user stories
- [ ] progress.txt exists (or will be created)
- [ ] On correct git branch
- [ ] Quality check commands are known
- [ ] Stories are small enough

During each iteration:

- [ ] Read progress.txt for context
- [ ] Work on ONE story only
- [ ] Run quality checks
- [ ] Update AGENTS.md if patterns discovered
- [ ] Commit with clear message
- [ ] Update prd.json
- [ ] Append to progress.txt

After completion:

- [ ] All stories marked passes: true
- [ ] All commits pushed (if applicable)
- [ ] Final summary provided
