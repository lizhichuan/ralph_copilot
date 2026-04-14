# Ralph for GitHub Copilot CLI

> Autonomous AI agent loop that runs inside GitHub Copilot CLI until all PRD items are complete.

Based on [snarktank/ralph](https://github.com/snarktank/ralph), adapted for GitHub Copilot CLI.

## Quick Start

```bash
# 1. Clone to your project root
git clone https://github.com/yourusername/ralph-copilot.git .ralph

# 2. Initialize
.ralph/init.sh

# 3. Run
copilot --experimental
# Then: Load the ralph-run skill and execute all pending stories
```

## Structure

```
your-project/
├── .ralph/           # Ralph core (clone here)
│   ├── skills/
│   ├── init.sh
│   └── update-prd.sh
├── prd.json          # User stories (project root)
├── progress.txt      # Progress log (project root)
└── tasks/            # PRD docs (project root)
```

## Usage

### 1. Create PRD

```bash
copilot --experimental
```
```
Load the prd skill and create a PRD for [feature]
```

### 2. Convert to Ralph Format

```
Load the ralph skill and convert tasks/prd-[name].md to prd.json
```

### 3. Run Ralph

```
Load the ralph-run skill and execute all pending stories
```

Or press `Shift+Tab` for **Autopilot** mode.

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

## Commands

```bash
.ralph/init.sh           # Initialize Ralph
.ralph/update-prd.sh US-001  # Mark story complete
jq '.userStories[] | select(.passes == false)' prd.json  # View pending
```

## License

MIT
