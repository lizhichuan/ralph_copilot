#!/bin/bash
# Ralph Wiggum - Autonomous AI agent loop for GitHub Copilot CLI
# Usage: ./ralph.sh [--experimental] [max_iterations]

set -e

# Parse arguments
MAX_ITERATIONS=10
EXPERIMENTAL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --experimental)
      EXPERIMENTAL=true
      shift
      ;;
    *)
      # Assume it's max_iterations if it's a number
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"
COPILOT_MD="$SCRIPT_DIR/COPilot.md"

# Check if prd.json exists
if [ ! -f "$PRD_FILE" ]; then
  echo "Error: prd.json not found in $SCRIPT_DIR"
  echo "Please create a prd.json file with your user stories."
  echo "See prd.json.example for reference."
  exit 1
fi

# Check if Copilot CLI is installed
if ! command -v copilot &> /dev/null; then
  echo "Error: GitHub Copilot CLI (copilot) not found."
  echo "Install it with:"
  echo "  curl -fsSL https://gh.io/copilot-install | bash"
  echo "  or: brew install copilot-cli"
  echo "  or: npm install -g @github/copilot"
  exit 1
fi

# Archive previous run if branch changed
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")
  
  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    # Archive the previous run
    DATE=$(date +%Y-%m-%d)
    # Strip "ralph/" prefix from branch name for folder
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"
    
    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"
    
    # Reset progress file for new run
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# Build copilot command
COPILOT_CMD="copilot"
if [ "$EXPERIMENTAL" = true ]; then
  COPILOT_CMD="$COPILOT_CMD --experimental"
fi

echo "Starting Ralph for GitHub Copilot CLI"
echo "Max iterations: $MAX_ITERATIONS"
if [ "$EXPERIMENTAL" = true ]; then
  echo "Experimental mode: ENABLED (Autopilot available)"
fi
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS"
  echo "==============================================================="
  
  # Check if all stories are complete
  if [ -f "$PRD_FILE" ]; then
    REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE" 2>/dev/null || echo "0")
    if [ "$REMAINING" -eq 0 ]; then
      echo ""
      echo "✓ All user stories completed!"
      echo "Ralph completed successfully at iteration $i of $MAX_ITERATIONS"
      exit 0
    fi
    echo "Remaining stories: $REMAINING"
  fi
  
  # Get the current branch from PRD and ensure we're on it
  if [ -f "$PRD_FILE" ]; then
    TARGET_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
    if [ -n "$TARGET_BRANCH" ]; then
      CURRENT_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
      if [ "$CURRENT_GIT_BRANCH" != "$TARGET_BRANCH" ]; then
        echo "Switching to branch: $TARGET_BRANCH"
        # Check if branch exists
        if git rev-parse --verify "$TARGET_BRANCH" &>/dev/null; then
          git checkout "$TARGET_BRANCH" 2>/dev/null || echo "Warning: Could not checkout $TARGET_BRANCH"
        else
          # Create new branch from main/master
          MAIN_BRANCH=$(git rev-parse --abbrev-ref main 2>/dev/null || echo "master")
          if git rev-parse --verify "$MAIN_BRANCH" &>/dev/null; then
            git checkout -b "$TARGET_BRANCH" "$MAIN_BRANCH" 2>/dev/null || echo "Warning: Could not create $TARGET_BRANCH"
          fi
        fi
      fi
    fi
  fi
  
  echo ""
  echo "Running Copilot CLI..."
  echo ""
  
  # Run Copilot CLI with the prompt
  # Use --print mode if available, otherwise use interactive mode with timeout
  if echo "$COPILOT_CMD" | grep -q "\-p\|--print"; then
    # Print mode (non-interactive)
    OUTPUT=$(cat "$COPILOT_MD" | $COPILOT_CMD 2>&1 | tee /dev/stderr) || true
  else
    # For Copilot CLI, we need to use a different approach
    # Create a temporary file with the prompt and use copilot's input
    OUTPUT=$(cat "$COPILOT_MD" | $COPILOT_CMD 2>&1 | tee /dev/stderr) || true
  fi
  
  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "✓ Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi
  
  echo ""
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
echo "Remaining stories:"
if [ -f "$PRD_FILE" ]; then
  jq '.userStories[] | select(.passes == false) | .title' "$PRD_FILE" 2>/dev/null || echo "  (unable to parse prd.json)"
fi
exit 1
