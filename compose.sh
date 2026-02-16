#!/bin/bash

# Docker Compose Compatibility Wrapper
# Automatically detects and uses the correct Docker Compose command

set -e

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect which Docker Compose version is available
if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    VERSION="V2 (Plugin)"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    VERSION="V1 (Standalone)"
else
    echo "Error: Neither 'docker compose' nor 'docker-compose' is available."
    echo "Please install Docker Compose. Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${BLUE}Using Docker Compose ${VERSION}${NC}"
echo -e "${BLUE}Command: ${COMPOSE_CMD}${NC}"
echo ""

# Pass all arguments to the detected compose command
$COMPOSE_CMD "$@"
