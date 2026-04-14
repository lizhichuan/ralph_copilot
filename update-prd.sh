#!/bin/bash
# Update prd.json to mark a story as complete
# Usage: ./update-prd.sh <story-id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"

if [ ! -f "$PRD_FILE" ]; then
  echo "Error: prd.json not found in $SCRIPT_DIR"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <story-id>"
  echo "Example: $0 US-001"
  exit 1
fi

STORY_ID="$1"

# Check if story exists
STORY_EXISTS=$(jq --arg id "$STORY_ID" '[.userStories[] | select(.id == $id)] | length' "$PRD_FILE")
if [ "$STORY_EXISTS" -eq 0 ]; then
  echo "Error: Story $STORY_ID not found in prd.json"
  exit 1
fi

# Update the story to passes: true
jq --arg id "$STORY_ID" '
  .userStories = [.userStories[] | if .id == $id then .passes = true else . end]
' "$PRD_FILE" > "$PRD_FILE.tmp" && mv "$PRD_FILE.tmp" "$PRD_FILE"

echo "✓ Updated story $STORY_ID: passes = true"

# Show remaining stories
REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE")
echo "Remaining stories: $REMAINING"

if [ "$REMAINING" -eq 0 ]; then
  echo "✓ All stories completed!"
fi
