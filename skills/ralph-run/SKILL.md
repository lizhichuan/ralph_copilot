---
name: ralph-run
description: "Run the Ralph autonomous agent loop inside Copilot CLI. Executes user stories from prd.json one by one until all are complete. Use when asked to run ralph, execute prd stories, or work autonomously."
user-invocable: true
---

# Ralph Autonomous Agent Loop for Copilot CLI

Run Ralph directly inside Copilot CLI - no bash script needed.

---

## The Job

1. Read `prd.json` from **project root** to get user stories
2. Read `progress.txt` from **project root** for context
3. Pick the highest priority story where `passes: false`
4. Implement that ONE story
5. Run quality checks (typecheck, lint, test, build)
6. Commit if checks pass
7. Update `prd.json` to mark story as `passes: true`
8. Append progress to `progress.txt`
9. Repeat until all stories complete

---

## How to Use

### Start Ralph in Copilot CLI

```bash
cd /path/to/your/project
copilot --experimental
```

Then say:

```
Load the ralph-run skill and execute all pending stories in prd.json
```

### With Autopilot Mode

1. Press `Shift+Tab` to cycle to **Autopilot** mode
2. Give the prompt above
3. Ralph will work autonomously until all stories complete

---

## File Locations

All runtime files are in the **project root**:

- `prd.json` - User stories and completion status
- `progress.txt` - Progress log and learned patterns
- `tasks/` - Generated PRD documents

The `.ralph/` directory contains only the Ralph skills and scripts.

---

## Before You Start

### 1. Verify prd.json exists in project root

```
Check if prd.json exists in the current directory
```

### 2. Verify progress.txt exists in project root

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

### Step 3: Run Quality Checks

Run the project's quality checks:
- Typecheck: `npm run typecheck`, `npx tsc --noEmit`, or equivalent
- Lint: `npm run lint` or equivalent  
- Test: `npm test` or equivalent
- Build: `npm run build` or equivalent

If checks fail, fix the issues before proceeding.

### Step 4: Commit

```bash
git add -A
git commit -m "feat: [Story ID] - [Story Title]"
```

### Step 5: Update prd.json

Set `passes: true` for the completed story:

```
Update prd.json to set passes: true for story [Story ID]
```

Or use jq:
```bash
jq '.userStories = [.userStories[] | if .id == "US-001" then .passes = true else . end]' prd.json > prd.json.tmp && mv prd.json.tmp prd.json
```

### Step 6: Update progress.txt

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

### Step 7: Check Completion

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
3. **Keep CI green** - Never commit broken code
4. **Small commits** - One commit per story
5. **Verify in browser** - For UI changes, visually confirm

---

## Checklist

Before running Ralph:

- [ ] prd.json exists in project root with user stories
- [ ] progress.txt exists in project root
- [ ] On correct git branch
- [ ] Stories are small enough

During each iteration:

- [ ] Read progress.txt for context
- [ ] Work on ONE story only
- [ ] Run quality checks
- [ ] Commit with clear message
- [ ] Update prd.json
- [ ] Append to progress.txt

After completion:

- [ ] All stories marked passes: true
- [ ] Final summary provided
