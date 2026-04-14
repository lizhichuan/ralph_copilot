#!/bin/bash
# Initialize Ralph in your project
# Usage: ./init-ralph.sh [project-name] [branch-name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Initializing Ralph for GitHub Copilot CLI"
echo ""

# Get project name
if [ -n "$1" ]; then
  PROJECT_NAME="$1"
else
  read -p "Enter project name: " PROJECT_NAME
fi

# Get branch name
if [ -n "$2" ]; then
  BRANCH_NAME="ralph/$2"
else
  read -p "Enter feature branch name (e.g., task-priority): " BRANCH_INPUT
  BRANCH_NAME="ralph/$BRANCH_INPUT"
fi

# Get description
read -p "Enter project description: " DESCRIPTION

# Check if prd.json already exists
if [ -f "$SCRIPT_DIR/prd.json" ]; then
  echo ""
  echo "⚠️  prd.json already exists!"
  read -p "Do you want to overwrite it? (y/N): " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "Skipping prd.json creation"
  fi
fi

# Create prd.json
if [ ! -f "$SCRIPT_DIR/prd.json" ] || [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
  cat > "$SCRIPT_DIR/prd.json" << EOF
{
  "project": "$PROJECT_NAME",
  "branchName": "$BRANCH_NAME",
  "description": "$DESCRIPTION",
  "userStories": [
    {
      "id": "US-001",
      "title": "[First user story title]",
      "description": "As a [user], I want to [action] so that [benefit].",
      "acceptanceCriteria": [
        "[Criterion 1]",
        "[Criterion 2]",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "[Second user story title]",
      "description": "As a [user], I want to [action] so that [benefit].",
      "acceptanceCriteria": [
        "[Criterion 1]",
        "Typecheck passes"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
EOF
  echo "✓ Created prd.json"
fi

# Create progress.txt
if [ ! -f "$SCRIPT_DIR/progress.txt" ]; then
  cp "$SCRIPT_DIR/progress.txt.template" "$SCRIPT_DIR/progress.txt"
  sed -i '' "s/\[Auto-filled on first run\]/$(date)/" "$SCRIPT_DIR/progress.txt" 2>/dev/null || \
    sed -i "s/\[Auto-filled on first run\]/$(date)/" "$SCRIPT_DIR/progress.txt"
  echo "✓ Created progress.txt"
fi

# Check if git repo exists
if ! git rev-parse --git-dir &> /dev/null; then
  echo ""
  echo "⚠️  No git repository found!"
  read -p "Do you want to initialize a git repository? (y/N): " INIT_GIT
  if [[ "$INIT_GIT" =~ ^[Yy]$ ]]; then
    git init
    git add .
    git commit -m "Initial commit: Add Ralph AI agent loop"
    echo "✓ Initialized git repository"
  fi
fi

echo ""
echo "✅ Ralph initialization complete!"
echo ""
echo "Next steps:"
echo "1. Edit prd.json to add your user stories"
echo "2. Make sure each story is small enough to complete in one iteration"
echo "3. Run: ./ralph.sh [max_iterations]"
echo ""
echo "Example:"
echo "  ./ralph.sh 20    # Run up to 20 iterations"
echo "  ./ralph.sh --experimental  # Enable experimental mode (Autopilot)"
echo ""
