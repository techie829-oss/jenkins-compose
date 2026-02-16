# Changes Summary - Docker Compose V2 Update

## What Changed?

All files have been updated to use **Docker Compose V2** syntax (`docker compose` without hyphen).

## Updated Files

### 1. README-enhanced.md
- ✅ All `docker-compose` commands changed to `docker compose`
- ✅ Added version check in Quick Start
- ✅ Added note about V1/V2 compatibility
- ✅ Reference to DOCKER_COMPOSE_V2.md guide

### 2. backup.sh
- ✅ Updated to use `docker compose` command

### 3. restore.sh
- ✅ Updated to use `docker compose` command

### 4. New Files Added

#### DOCKER_COMPOSE_V2.md
- Complete guide comparing V1 vs V2
- Command reference table
- Migration instructions
- Installation guide

#### compose.sh
- Compatibility wrapper script
- Auto-detects which version you have
- Works with both V1 and V2
- Usage: `./compose.sh [any compose command]`

## Quick Start Command Changes

| Old (V1) | New (V2) |
|----------|----------|
| `docker-compose up -d` | `docker compose up -d` |
| `docker-compose down` | `docker compose down` |
| `docker-compose logs -f` | `docker compose logs -f` |
| `docker-compose ps` | `docker compose ps` |

## For V1 Users

If you're still using Docker Compose V1 (`docker-compose`):

**Option 1:** Use the compatibility wrapper
```bash
./compose.sh up -d
./compose.sh down
./compose.sh logs -f
```

**Option 2:** Create an alias
```bash
alias docker-compose='docker compose'
```

**Option 3:** Manually replace commands
Just use `docker-compose` instead of `docker compose` in all commands.

## Files Structure

```
jenkins-compose/
├── README-enhanced.md          # Main documentation (V2 syntax)
├── DOCKER_COMPOSE_V2.md       # V1 vs V2 guide
├── docker-compose.yml         # Simple setup
├── docker-compose-dind.yml    # Docker-in-Docker setup
├── backup.sh                  # Backup script (V2 syntax)
├── restore.sh                 # Restore script (V2 syntax)
├── compose.sh                 # Compatibility wrapper
├── .env.example              # Environment variables template
└── .gitignore                # Git ignore rules
```

## Testing Your Version

```bash
# Test Docker Compose V2
docker compose version

# If that fails, test V1
docker-compose version

# Or use the wrapper (works with both)
./compose.sh version
```

## Benefits of V2

- 🚀 **Faster:** Improved performance
- 🔧 **Built-in:** No separate installation
- 📦 **Better integration:** Part of Docker CLI
- 🎯 **Active development:** V1 is in maintenance mode
- 🔮 **Future-proof:** All new features in V2

## Backward Compatibility

Good news: Your `docker-compose.yml` files work with **both** V1 and V2!

The only difference is the command you use to run them.

---

**Bottom line:** This repository now uses modern Docker Compose V2 syntax, but everything still works with V1 if needed.
