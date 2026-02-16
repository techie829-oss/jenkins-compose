#!/bin/bash

# Jenkins Quick Start Script
# Sets up Jenkins with basic configuration

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[→]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
     ___           _    _           
    |_  |         | |  (_)          
      | | ___ _ __| | ___ _ __  ___ 
      | |/ _ \ '_ \ |/ / | '_ \/ __|
  /\__/ /  __/ | | |   <| | | \__ \
  \____/ \___|_| |_|_|\_\_|_| |___/
                                    
  Quick Start Setup
EOF
echo -e "${NC}"

# Check prerequisites
log_step "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    log_info "Docker Compose V2 detected"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    log_info "Docker Compose V1 detected"
else
    log_error "Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    log_step "Creating .env file from template..."
    cp .env.example .env
    log_info ".env file created"
    log_warn "Review .env file and adjust settings if needed"
else
    log_info ".env file already exists"
fi

# Check if Jenkins is already running
if docker ps | grep -q jenkins; then
    log_warn "Jenkins container is already running"
    read -p "Do you want to restart it? (y/n): " RESTART
    if [ "$RESTART" = "y" ]; then
        log_step "Restarting Jenkins..."
        $COMPOSE_CMD restart jenkins
        log_info "Jenkins restarted"
    fi
else
    # Check if image needs to be built
    if ! docker images | grep -q "myjenkins-blueocean"; then
        log_step "Building custom Jenkins image (this may take a few minutes)..."
        $COMPOSE_CMD build
        log_info "Image built successfully"
    else
        log_info "Jenkins image already exists"
    fi
    
    # Start Jenkins
    log_step "Starting Jenkins..."
    $COMPOSE_CMD up -d
    
    # Wait for Jenkins to start
    log_step "Waiting for Jenkins to start (this may take 1-2 minutes)..."
    sleep 15
    
    # Check if container is running
    if docker ps | grep -q jenkins; then
        log_info "Jenkins container is running"
        
        # Wait a bit more for Jenkins to fully initialize
        log_step "Waiting for Jenkins to initialize..."
        sleep 30
        
        # Try to get initial password
        log_step "Retrieving initial admin password..."
        if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword; then
            PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}║        🔐 Initial Admin Password 🔐           ║${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}╠════════════════════════════════════════════════╣${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}║  ${YELLOW}${PASSWORD}${GREEN}  ║${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
            echo ""
        else
            log_warn "Could not retrieve initial password yet. Try again in a minute:"
            echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
        fi
        
        # Detect access URL
        if command -v ip &> /dev/null; then
            SERVER_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)
        else
            SERVER_IP="<your-server-ip>"
        fi
        
        echo ""
        log_info "Jenkins is starting up!"
        echo ""
        echo -e "${BLUE}Access Jenkins at:${NC}"
        echo -e "  • Local:  ${GREEN}http://localhost:8080${NC}"
        echo -e "  • Remote: ${GREEN}http://${SERVER_IP}:8080${NC}"
        echo ""
        echo -e "${BLUE}Next Steps:${NC}"
        echo "  1. Open Jenkins in your browser"
        echo "  2. Use the password above to unlock Jenkins"
        echo "  3. Install suggested plugins"
        echo "  4. Create your first admin user"
        echo ""
        echo -e "${YELLOW}For domain setup (Nginx + SSL), see:${NC}"
        echo "  • README.md (Section: Production Setup)"
        echo "  • docs/DOMAIN_SETUP.md (Domain configuration)"
        echo ""
        echo -e "${BLUE}Useful commands:${NC}"
        echo "  • View logs:    ${GREEN}$COMPOSE_CMD logs -f jenkins${NC}"
        echo "  • Stop:         ${GREEN}$COMPOSE_CMD down${NC}"
        echo "  • Restart:      ${GREEN}$COMPOSE_CMD restart jenkins${NC}"
        echo "  • Get password: ${GREEN}docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword${NC}"
        echo ""
        
    else
        log_error "Jenkins container failed to start"
        echo "Check logs with: $COMPOSE_CMD logs jenkins"
        exit 1
    fi
fi
