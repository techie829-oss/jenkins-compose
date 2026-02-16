#!/bin/bash

# Docker Compose Compatibility Wrapper
# Automatically detects available Docker Compose version (V1 or V2)

if docker compose version >/dev/null 2>&1; then
    # Docker Compose V2 detected
    exec docker compose "$@"
elif command -v docker-compose >/dev/null 2>&1; then
    # Docker Compose V1 detected
    exec docker-compose "$@"
else
    echo "Error: Docker Compose not found."
    exit 1
fi
