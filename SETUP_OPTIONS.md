# Jenkins Setup Options

This repository provides **two setup options** based on the official Jenkins Docker documentation.

## 📋 Quick Comparison

| Feature | Simple Setup | Docker-in-Docker Setup |
|---------|-------------|----------------------|
| **File** | `docker-compose.yml` | `docker-compose-dind.yml` |
| **Containers** | 1 (Jenkins only) | 2 (Jenkins + Docker daemon) |
| **Docker Builds** | ❌ Not supported by default | ✅ Fully supported |
| **Security** | ⚠️ Moderate | ✅ Isolated |
| **Setup Time** | ~2 minutes | ~3-5 minutes |
| **Disk Space** | ~2 GB | ~3 GB |
| **Best For** | Testing, no Docker builds | Production, CI/CD pipelines |

---

## Option 1: Simple Setup (Recommended for Beginners)

**Use this if:**
- You're just testing Jenkins
- You don't need to build Docker images in Jenkins
- You want the quickest setup

### What's Included:
- ✅ Jenkins with Blue Ocean UI
- ✅ Docker CLI installed (but no daemon)
- ✅ Essential plugins pre-installed
- ✅ Configuration as Code ready

### Quick Start:
```bash
# Build and start
docker compose up -d

# Or use the automated script
./start.sh
```

### Architecture:
```
┌─────────────────┐
│     Jenkins     │
│  (Blue Ocean)   │
│   + Docker CLI  │
└─────────────────┘
```

### What You CAN Do:
- ✅ Run Jenkins jobs
- ✅ Use Blue Ocean UI
- ✅ Configure pipelines
- ✅ Install plugins
- ✅ Use Git integration

### What You CANNOT Do:
- ❌ Build Docker images in pipelines
- ❌ Run Docker commands in Jenkins
- ❌ Use Docker agents

---

## Option 2: Docker-in-Docker Setup (Recommended for Production)

**Use this if:**
- You need to build Docker images in Jenkins
- You're running CI/CD pipelines
- You want production-ready security
- You plan to use Jenkins with Docker

### What's Included:
- ✅ Everything from Simple Setup
- ✅ Separate Docker daemon container
- ✅ Secure TLS communication
- ✅ Full Docker build capability
- ✅ Isolated environment

### Quick Start:
```bash
# Build and start both containers
docker compose -f docker-compose-dind.yml up -d
```

### Architecture:
```
┌─────────────────┐     TLS      ┌──────────────────┐
│     Jenkins     │◄────────────►│  Docker Daemon   │
│  (Blue Ocean)   │   (2376)     │      (dind)      │
│   + Docker CLI  │              │                  │
└─────────────────┘              └──────────────────┘
        │                                 │
        └─────────► jenkins-data ◄───────┘
```

### What You CAN Do:
- ✅ Everything from Simple Setup
- ✅ Build Docker images
- ✅ Run Docker containers
- ✅ Use Docker Compose in builds
- ✅ Multi-stage Docker builds
- ✅ Docker-based testing

---

## Detailed Setup Instructions

### Option 1: Simple Setup

**Step 1: Build the image**
```bash
docker compose build
```

**Step 2: Start Jenkins**
```bash
docker compose up -d
```

**Step 3: Get initial password**
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Step 4: Access Jenkins**
- Open: `http://localhost:8080`
- Use the password from Step 3

---

### Option 2: Docker-in-Docker Setup

**Step 1: Build the image**
```bash
docker compose -f docker-compose-dind.yml build
```

**Step 2: Start both containers**
```bash
docker compose -f docker-compose-dind.yml up -d
```

**Step 3: Wait for initialization**
```bash
# This takes a bit longer than simple setup
# Wait about 2-3 minutes for both containers to be ready
docker compose -f docker-compose-dind.yml logs -f
```

**Step 4: Get initial password**
```bash
docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
```

**Step 5: Access Jenkins**
- Open: `http://localhost:8080`
- Use the password from Step 4

**Step 6: Test Docker (Optional)**
```bash
# Enter Jenkins container
docker exec -it jenkins-blueocean bash

# Try Docker command
docker version

# Should show client and server info
```

---

## Switching Between Setups

### From Simple to Docker-in-Docker

**Keep your data:**
```bash
# Stop simple setup
docker compose down

# Start DinD setup (reuses jenkins-data volume)
docker compose -f docker-compose-dind.yml up -d
```

### From Docker-in-Docker to Simple

**Keep your data:**
```bash
# Stop DinD setup
docker compose -f docker-compose-dind.yml down

# Start simple setup (reuses jenkins-data volume)
docker compose up -d
```

⚠️ **Warning:** If you switch from DinD to Simple, your Docker-based pipelines will stop working.

---

## Technical Details

### Simple Setup (docker-compose.yml)

**Image Build Process:**
1. Starts from `jenkins/jenkins:2.541.1-jdk21`
2. Installs Docker CLI (client only)
3. Pre-installs plugins:
   - Blue Ocean (modern UI)
   - Docker Workflow (Docker pipeline support)
   - JSON Path API (dependency)
   - Configuration as Code (JCasC)

**Restart Policy:** `on-failure`
- Restarts automatically if crashes
- Manual stops are respected

**Network:** Bridge network named `jenkins`

**Volumes:**
- `jenkins-data`: Persistent Jenkins configuration and data

---

### Docker-in-Docker Setup (docker-compose-dind.yml)

**Additional Container: jenkins-docker**
- Image: `docker:dind`
- Runs privileged (required for Docker-in-Docker)
- Storage driver: `overlay2`
- Exposes port 2376 (Docker API)

**TLS Security:**
- Certificates stored in `jenkins-docker-certs` volume
- Jenkins connects via TLS to Docker daemon
- Environment variables:
  - `DOCKER_HOST=tcp://docker:2376`
  - `DOCKER_CERT_PATH=/certs/client`
  - `DOCKER_TLS_VERIFY=1`

**Shared Volumes:**
- `jenkins-data`: Jenkins home directory (shared)
- `jenkins-docker-certs`: TLS certificates (shared read-only)

**Why Privileged Mode?**
The Docker daemon container needs privileged access to:
- Create containers
- Manage networks
- Access storage drivers
- Handle kernel features

This is **contained** to the Docker daemon container only, not Jenkins.

---

## Plugin Details

Both setups include these pre-installed plugins:

### Blue Ocean
- Modern, visual pipeline editor
- Better UI/UX than classic Jenkins
- Pipeline visualization
- Built-in Git integration

### Docker Workflow
- `docker.build()` step
- `docker.image()` support
- Dockerfile pipeline syntax
- Docker agent support

### Configuration as Code (JCasC)
- YAML-based configuration
- Version control your Jenkins setup
- Automated deployment
- See `jenkins-casc-template.yaml`

### JSON Path API
- Required dependency
- JSON processing support

---

## Performance Considerations

### Simple Setup
- **Memory:** ~512 MB minimum
- **Disk:** ~2 GB for Jenkins + data
- **CPU:** Minimal (1 core sufficient)
- **Startup:** ~60-90 seconds

### Docker-in-Docker Setup
- **Memory:** ~1 GB minimum (512 MB each container)
- **Disk:** ~3 GB (Jenkins + Docker daemon + images)
- **CPU:** 2 cores recommended
- **Startup:** ~90-120 seconds

### Production Recommendations
- **Memory:** 4+ GB RAM
- **Disk:** 50+ GB (for builds and artifacts)
- **CPU:** 4+ cores
- **Executors:** 2 per core (configure in Jenkins)

---

## Security Considerations

### Simple Setup Security
✅ No Docker daemon access
✅ Standard Jenkins security
⚠️ Cannot build Docker images
⚠️ Less isolation

### Docker-in-Docker Security
✅ **Isolated Docker daemon** - Not shared with host
✅ **TLS encrypted** - Secure communication
✅ **Separate network** - Network isolation
⚠️ **Privileged container** - Docker daemon runs privileged
✅ **Volume isolation** - Data separated from host

**Important:** The DinD setup is MORE secure than mounting the host Docker socket (`/var/run/docker.sock`) because:
1. Isolated daemon (attacks can't affect host)
2. TLS encryption (network security)
3. No direct host access (limited blast radius)

---

## Troubleshooting

### Simple Setup Issues

**Problem:** "docker: command not found" in pipeline

**Solution:** This is expected. Use Docker-in-Docker setup if you need Docker.

---

### Docker-in-Docker Issues

**Problem:** "Cannot connect to Docker daemon"

**Check:**
```bash
# Is Docker daemon running?
docker ps | grep jenkins-docker

# Check logs
docker compose -f docker-compose-dind.yml logs docker

# Verify certificates
docker exec jenkins-blueocean ls -la /certs/client
```

**Solution:**
```bash
# Restart both containers
docker compose -f docker-compose-dind.yml restart
```

---

**Problem:** "TLS handshake timeout"

**Solution:**
```bash
# Remove volumes and start fresh
docker compose -f docker-compose-dind.yml down -v
docker compose -f docker-compose-dind.yml up -d
```

---

## Which Setup Should You Use?

### Choose Simple Setup if:
- 🎯 You're learning Jenkins
- 📚 You're following tutorials
- 🔍 You're evaluating Jenkins features
- ⚡ You want the fastest setup
- 🎨 You only need the web UI
- 📝 Your pipelines don't use Docker

### Choose Docker-in-Docker Setup if:
- 🏭 You're setting up production CI/CD
- 🐳 Your builds need Docker
- 🔨 You're building Docker images
- 🧪 You're running tests in containers
- 🚀 You're deploying to Kubernetes
- 🔐 You need secure Docker access

### Still Unsure?

**Start with Simple Setup:**
1. It's faster to test
2. Uses less resources
3. Easier to understand
4. Can switch to DinD later (keeps data)

**Upgrade to DinD when you need:**
- Docker build capability
- Container-based testing
- Production deployment

---

## Official Documentation

Both setups follow the official Jenkins Docker installation guide:
https://www.jenkins.io/doc/book/installing/docker/

**Key Differences from Official Docs:**
- ✅ We use Docker Compose (easier than manual commands)
- ✅ We add health checks (better reliability)
- ✅ We add DNS servers (fixes offline issues)
- ✅ We use environment variables (easier customization)
- ✅ We separate concerns (docker-compose.yml vs docker-compose-dind.yml)

---

## Next Steps

After choosing and setting up:

1. ✅ Complete initial setup wizard
2. ✅ Configure domain (see `DOMAIN_SETUP.md`)
3. ✅ Set up Nginx + SSL (see `README-enhanced.md`)
4. ✅ Configure backups (use `backup.sh`)
5. ✅ Create your first pipeline

---

**Need Help?**
- 📖 See `README-enhanced.md` for complete documentation
- 🏗️ See `PROJECT_STRUCTURE.md` for file organization
- 🌐 See `DOMAIN_SETUP.md` for domain configuration
- 🔍 Check troubleshooting sections above
