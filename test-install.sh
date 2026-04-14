#!/bin/bash
# Test script for Ralph - Verify installation and setup
# Usage: ./test-install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Ralph Installation Test"
echo "=========================="
echo ""

# Test 1: Check required files
echo "1. Checking required files..."
REQUIRED_FILES=("ralph.sh" "COPilot.md" "prd.json.example" "init-ralph.sh" "quality-check.sh" "update-prd.sh")
ALL_FILES_EXIST=true

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    echo "   ✓ $file"
  else
    echo "   ✗ $file (MISSING)"
    ALL_FILES_EXIST=false
  fi
done

if [ "$ALL_FILES_EXIST" = false ]; then
  echo ""
  echo "❌ Some required files are missing!"
  exit 1
fi

# Test 2: Check scripts are executable
echo ""
echo "2. Checking script permissions..."
EXECUTABLE_SCRIPTS=("ralph.sh" "init-ralph.sh" "quality-check.sh" "update-prd.sh")
ALL_EXECUTABLE=true

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
  if [ -x "$SCRIPT_DIR/$script" ]; then
    echo "   ✓ $script is executable"
  else
    echo "   ✗ $script is NOT executable"
    ALL_EXECUTABLE=false
  fi
done

if [ "$ALL_EXECUTABLE" = false ]; then
  echo ""
  echo "⚠️  Some scripts are not executable. Run: chmod +x *.sh"
fi

# Test 3: Check GitHub Copilot CLI
echo ""
echo "3. Checking GitHub Copilot CLI..."
if command -v copilot &> /dev/null; then
  COPILOT_VERSION=$(copilot --version 2>&1 | head -1 || echo "unknown")
  echo "   ✓ Copilot CLI installed: $COPILOT_VERSION"
else
  echo "   ✗ Copilot CLI NOT installed"
  echo ""
  echo "   Install with:"
  echo "     curl -fsSL https://gh.io/copilot-install | bash"
  echo "   or:"
  echo "     brew install copilot-cli"
  echo "   or:"
  echo "     npm install -g @github/copilot"
fi

# Test 4: Check jq
echo ""
echo "4. Checking jq..."
if command -v jq &> /dev/null; then
  JQ_VERSION=$(jq --version)
  echo "   ✓ jq installed: $JQ_VERSION"
else
  echo "   ✗ jq NOT installed"
  echo ""
  echo "   Install with:"
  echo "     brew install jq  # macOS"
  echo "     sudo apt-get install jq  # Linux"
fi

# Test 5: Check git
echo ""
echo "5. Checking git..."
if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version)
  echo "   ✓ git installed: $GIT_VERSION"
else
  echo "   ✗ git NOT installed"
fi

# Test 6: Validate prd.json.example
echo ""
echo "6. Validating prd.json.example..."
if jq empty "$SCRIPT_DIR/prd.json.example" 2>/dev/null; then
  STORY_COUNT=$(jq '.userStories | length' "$SCRIPT_DIR/prd.json.example")
  echo "   ✓ Valid JSON with $STORY_COUNT user stories"
else
  echo "   ✗ Invalid JSON format"
fi

# Summary
echo ""
echo "=========================="
echo "Test Summary"
echo "=========================="

PASSED=0
FAILED=0

if [ "$ALL_FILES_EXIST" = true ]; then ((PASSED++)); else ((FAILED++)); fi
if [ "$ALL_EXECUTABLE" = true ]; then ((PASSED++)); else ((FAILED++)); fi
if command -v copilot &> /dev/null; then ((PASSED++)); else ((FAILED++)); fi
if command -v jq &> /dev/null; then ((PASSED++)); else ((FAILED++)); fi
if command -v git &> /dev/null; then ((PASSED++)); else ((FAILED++)); fi
if jq empty "$SCRIPT_DIR/prd.json.example" 2>/dev/null; then ((PASSED++)); else ((FAILED++)); fi

echo "Passed: $PASSED/6"
echo "Failed: $FAILED/6"

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "✅ All tests passed! Ralph is ready to use."
  echo ""
  echo "Next steps:"
  echo "  1. Run: copilot (to authenticate if needed)"
  echo "  2. Copy files to your project: cp -r $SCRIPT_DIR/* /path/to/your/project/scripts/ralph/"
  echo "  3. Run: ./init-ralph.sh"
  echo "  4. Edit prd.json with your user stories"
  echo "  5. Run: ./ralph.sh"
  exit 0
else
  echo ""
  echo "⚠️  Some tests failed. Please fix the issues above before using Ralph."
  exit 1
fi
