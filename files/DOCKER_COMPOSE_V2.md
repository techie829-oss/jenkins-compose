# Docker Compose V1 vs V2 Quick Reference

## What Changed?

Docker Compose V2 is now integrated as a Docker CLI plugin, changing the command from `docker-compose` to `docker compose`.

## Command Comparison

| Docker Compose V1 (old) | Docker Compose V2 (new) |
|------------------------|------------------------|
| `docker-compose up -d` | `docker compose up -d` |
| `docker-compose down` | `docker compose down` |
| `docker-compose logs -f` | `docker compose logs -f` |
| `docker-compose ps` | `docker compose ps` |
| `docker-compose restart` | `docker compose restart` |
| `docker-compose pull` | `docker compose pull` |
| `docker-compose build` | `docker compose build` |
| `docker-compose exec` | `docker compose exec` |

## Checking Your Version

```bash
# Check if you have Docker Compose V2 (plugin)
docker compose version

# Check if you have Docker Compose V1 (standalone)
docker-compose version
```

## Installation

### Docker Compose V2 (Recommended)

Docker Compose V2 comes bundled with:
- Docker Desktop (Windows/Mac)
- Docker Engine 20.10.0+ (Linux)

**For Linux, if not included:**
```bash
# Update Docker to latest version
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
docker compose version
```

### Docker Compose V1 (Legacy)

If you still need V1:
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Migration Tips

1. **Both can coexist:** You can have both V1 and V2 installed simultaneously
2. **Same YAML files:** Your `docker-compose.yml` files work with both versions
3. **Aliases:** If you prefer the old command, create an alias:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias docker-compose='docker compose'
   ```

## Why Upgrade to V2?

✅ **Better Performance:** Faster build and deployment times
✅ **Built-in:** No separate installation needed
✅ **Better Integration:** Works seamlessly with Docker CLI
✅ **Active Development:** V1 is in maintenance mode
✅ **GPU Support:** Better GPU resource handling
✅ **Profiles:** Better support for compose profiles

## Breaking Changes

Most commands are identical, but a few differences exist:

### Network Names
- V1: `projectname_networkname`
- V2: `projectname-networkname` (uses hyphens instead of underscores)

### Exit Codes
Some commands may return different exit codes in edge cases.

## This Repository

This repository uses **Docker Compose V2** syntax (`docker compose`).

If you're using V1, simply replace `docker compose` with `docker-compose` in all commands.
