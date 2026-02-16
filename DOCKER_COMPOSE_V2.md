# Docker Compose V2 Migration Guide

This repository has been updated to use **Docker Compose V2** syntax.

## Key Differences

| Feature | V1 (Old) | V2 (New) |
|---------|----------|----------|
| **Command** | `docker-compose` | `docker compose` |
| **Separation** | Standalone binary (usually Python) | Docker CLI Plugin (Go) |
| **Integrations** | Separate installation | Integrated into Docker Desktop/CLI |

## How to Migrate

### If you have Docker Desktop (Mac/Windows)
You likely already have V2 installed. Just use `docker compose` instead of `docker-compose`.

### If you are on Linux
1.  Uninstall `docker-compose`.
2.  Install the specific plugin:
    ```bash
    sudo apt-get install docker-compose-plugin
    ```

## Backward Compatibility

A wrapper script `compose.sh` is included in this repository. It automatically detects which version you have installed and runs the appropriate command.

**Usage:**
```bash
./compose.sh up -d
./compose.sh down
./compose.sh logs -f
```
