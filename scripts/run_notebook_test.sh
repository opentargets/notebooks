#!/bin/bash
# Helper script to run notebook tests
# This script can be used locally or in CI/CD environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting notebook smoke tests...${NC}"

# Check if a specific notebook was provided
NOTEBOOK_FILTER="${1:-}"

# Set up environment
export PYTHONUNBUFFERED=1

# Change to project root
cd "$(dirname "$0")/.."

# Install dependencies if needed
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}Installing uv...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Sync dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
uv sync --all-extras

# Run tests
echo -e "${YELLOW}Running notebook tests...${NC}"
if [ -n "$NOTEBOOK_FILTER" ]; then
    echo -e "${YELLOW}Testing specific notebook: $NOTEBOOK_FILTER${NC}"
    uv run pytest tests/test_notebooks.py -v -k "$NOTEBOOK_FILTER"
else
    echo -e "${YELLOW}Testing all notebooks${NC}"
    uv run pytest tests/ -v -m notebook
fi

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All notebook tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Notebook tests failed${NC}"
    exit $TEST_EXIT_CODE
fi

