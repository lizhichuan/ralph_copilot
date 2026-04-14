# Ralph for GitHub Copilot CLI

> Autonomous AI agent loop that runs inside GitHub Copilot CLI until all PRD items are complete.

Based on [snarktank/ralph](https://github.com/snarktank/ralph), adapted for GitHub Copilot CLI.

**Repository**: https://github.com/lizhichuan/ralph_copilot

---

## Quick Start

```bash
# 1. Clone to your project root
git clone git@github.com:lizhichuan/ralph_copilot.git .ralph

# 2. Initialize
.ralph/init.sh

# 3. Run
copilot --experimental
# Then: Load the ralph-run skill and execute all pending stories
```

---

## Structure

```
your-project/
├── .ralph/           # Ralph core (clone here)
│   ├── skills/
│   │   ├── prd/      # PRD generator
│   │   ├── ralph/    # PRD to JSON converter
│   │   └── ralph-run/# Autonomous agent runner
│   ├── init.sh       # Initialize Ralph
│   └── update-prd.sh # Update story status
├── prd.json          # User stories (project root)
├── progress.txt      # Progress log (project root)
└── tasks/            # PRD documents (project root)
```

---

## Usage

### 1. Create PRD

```bash
copilot --experimental
```

```
Load the prd skill and create a PRD for [feature]
```

Creates PRD in `tasks/prd-[feature].md`.

### 2. Convert to Ralph Format

```
Load the ralph skill and convert tasks/prd-[name].md to prd.json
```

### 3. Run Ralph

```
Load the ralph-run skill and execute all pending stories
```

Or press `Shift+Tab` for **Autopilot** mode.

---

## prd.json Format

```json
{
  "project": "YourProject",
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

---

## Commands

```bash
.ralph/init.sh                                    # Initialize Ralph
.ralph/update-prd.sh US-001                       # Mark story complete
jq '.userStories[] | select(.passes == false)' prd.json  # View pending
cat progress.txt                                  # View progress
```

---

## Skills

| Skill | Description | Trigger |
|-------|-------------|---------|
| `prd` | Generate PRD | "create a prd for..." |
| `ralph` | Convert PRD to JSON | "convert to prd.json" |
| `ralph-run` | Run Ralph | "execute all pending stories" |

---

## Best Practices

### Story Size

✅ **Good (one iteration):**
- Add database column + migration
- Add UI component to existing page
- Update API endpoint logic

❌ **Too big (split it):**
- "Build entire dashboard"
- "Add authentication system"
- "Refactor API layer"

### Story Order

1. Database/schema changes
2. Backend logic
3. UI components
4. Dashboard/summary views

### Acceptance Criteria

Must be verifiable:

✅ **Good:**
- "Add `status` column with default 'pending'"
- "Dropdown has options: All, Active, Completed"
- "Typecheck passes"

❌ **Bad:**
- "Works correctly"
- "Good UX"

---

## Troubleshooting

### Copilot CLI not installed

```bash
curl -fsSL https://gh.io/copilot-install | bash
```

### Authentication issues

```bash
copilot /login
```

### prd.json format error

```bash
jq empty prd.json  # Validate JSON
```

---

## License

MIT
