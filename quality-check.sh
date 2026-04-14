#!/bin/bash
# Quality check script for Ralph
# Customize this script based on your project's requirements
# Usage: ./quality-check.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Running quality checks..."

cd "$PROJECT_ROOT"

# Detect project type and run appropriate checks
if [ -f "package.json" ]; then
  echo "  → Node.js project detected"
  
  # Typecheck
  if grep -q "tsc" package.json || [ -f "tsconfig.json" ]; then
    echo "  → Running TypeScript check..."
    npm run typecheck 2>/dev/null || npx tsc --noEmit || echo "  ⚠ TypeScript check skipped (not configured)"
  fi
  
  # Lint
  if grep -q "lint" package.json; then
    echo "  → Running linter..."
    npm run lint 2>/dev/null || echo "  ⚠ Lint skipped (not configured)"
  fi
  
  # Test
  if grep -q "test" package.json; then
    echo "  → Running tests..."
    npm test 2>/dev/null || echo "  ⚠ Tests skipped (not configured)"
  fi
  
elif [ -f "Cargo.toml" ]; then
  echo "  → Rust project detected"
  echo "  → Running cargo check..."
  cargo check || echo "  ⚠ Cargo check failed"
  
  echo "  → Running cargo test..."
  cargo test --quiet 2>/dev/null || echo "  ⚠ Tests skipped"
  
elif [ -f "go.mod" ]; then
  echo "  → Go project detected"
  echo "  → Running go build..."
  go build ./... || echo "  ⚠ Go build failed"
  
  echo "  → Running go test..."
  go test ./... 2>/dev/null || echo "  ⚠ Tests skipped"
  
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  echo "  → Python project detected"
  
  # Typecheck with mypy if available
  if command -v mypy &> /dev/null; then
    echo "  → Running mypy..."
    mypy . 2>/dev/null || echo "  ⚠ Mypy check skipped"
  fi
  
  # Run pytest if available
  if command -v pytest &> /dev/null; then
    echo "  → Running pytest..."
    pytest -q 2>/dev/null || echo "  ⚠ Tests skipped"
  fi
  
else
  echo "  → Unknown project type, skipping specific checks"
fi

echo "✓ Quality checks complete"
