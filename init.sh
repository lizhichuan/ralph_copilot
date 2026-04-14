#!/bin/bash
# Ralph Initialization Script
# Run this in your project root to set up Ralph
# Usage: .ralph/init.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Initializing Ralph in: $PROJECT_ROOT"
echo ""

# Check if prd.json already exists
if [ -f "$PROJECT_ROOT/prd.json" ]; then
  echo "⚠️  prd.json already exists in project root"
  read -p "  Overwrite? (y/N): " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "  Skipping prd.json creation"
  fi
fi

# Create prd.json if it doesn't exist or user agreed to overwrite
if [ ! -f "$PROJECT_ROOT/prd.json" ] || [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
  cat > "$PROJECT_ROOT/prd.json" << 'EOF'
{
  "project": "YourProject",
  "branchName": "ralph/feature-name",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "First user story",
      "description": "As a [user], I want [feature] so that [benefit].",
      "acceptanceCriteria": [
        "Specific verifiable criterion 1",
        "Specific verifiable criterion 2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
EOF
  echo "✓ Created prd.json in project root"
fi

# Check if progress.txt already exists
if [ ! -f "$PROJECT_ROOT/progress.txt" ]; then
  cat > "$PROJECT_ROOT/progress.txt" << EOF
# Ralph Progress Log

Started: $(date)

---

## Codebase Patterns

[Add reusable patterns here as you discover them during iterations]

### Project Structure
- Describe your project structure here

### Key Commands
- Add important project commands here

### Conventions
- List project conventions here

---

## Iteration Log

EOF
  echo "✓ Created progress.txt in project root"
fi

# Create tasks directory
if [ ! -d "$PROJECT_ROOT/tasks" ]; then
  mkdir -p "$PROJECT_ROOT/tasks"
  echo "✓ Created tasks/ directory in project root"
fi

# Check git status
echo ""
if git rev-parse --git-dir &> /dev/null; then
  echo "✓ Git repository detected"
  echo ""
  echo "Next steps:"
  echo "  1. Edit prd.json with your user stories"
  echo "  2. Run: copilot --experimental"
  echo "  3. In Copilot CLI: Load the ralph-run skill and execute all pending stories"
else
  echo "⚠️  No git repository found!"
  echo ""
  read -p "Initialize git repository? (y/N): " INIT_GIT
  if [[ "$INIT_GIT" =~ ^[Yy]$ ]]; then
    cd "$PROJECT_ROOT"
    git init
    git add .
    git commit -m "Initial commit: Add Ralph AI agent loop"
    echo "✓ Initialized git repository"
  fi
fi

echo ""
echo "✅ Ralph initialization complete!"
echo ""
echo "Quick start:"
echo "  1. Edit prd.json to add your user stories"
echo "  2. copilot --experimental"
echo "  3. Load the ralph-run skill and execute all pending stories"
echo ""
echo "Documentation: https://github.com/yourusername/ralph-copilot"
