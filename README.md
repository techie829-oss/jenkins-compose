# Jenkins with Docker Compose

This repository contains a Docker Compose setup to run Jenkins using the official LTS image. It includes instructions for setting up a production-ready environment with Nginx and SSL.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed.
- [Docker Compose](https://docs.docker.com/compose/install/) installed.
- A registered domain name (for production setup).

## Quick Start

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/techie829-oss/jenkins-compose.git
    cd jenkins-compose
    ```

2.  **Start Jenkins:**
    ```bash
    docker-compose up -d
    ```

3.  **Unlock Jenkins:**
    - Browse to `http://localhost:8080` (or `http://<your-server-ip>:8080`).
    - Get the initial password:
      ```bash
      docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
      ```
    - Paste the password to unlock Jenkins.

## Production Setup Guide (Step-by-Step)

This guide assumes you are a **non-root user** with `sudo` privileges.

### Step 1: Verify Initial Access
Before setting up a domain, ensure Jenkins is running and accessible via your server's IP:
`http://<your-server-ip>:8080`

### Step 2: Nginx Reverse Proxy Setup

#### Check if Nginx is installed
Run the following command to check:
```bash
nginx -v
```

**Scenario A: Nginx is NOT installed**
Install it using:
```bash
sudo apt update
sudo apt install -y nginx
```

**Scenario B: Nginx is already installed**
Proceed to configuration.

#### Configure Nginx
1.  Create a configuration file for Jenkins:
    ```bash
    sudo nano /etc/nginx/sites-available/jenkins
    ```
2.  Paste the following configuration (replace `jenkins.yourdomain.com` with your actual domain):
    ```nginx
    server {
        listen 80;
        server_name jenkins.yourdomain.com;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```
3.  Enable the site and restart Nginx:
    ```bash
    sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    ```

### Step 3: SSL Setup (Certbot)

Secure your domain with a free Let's Encrypt certificate.

#### Check if Certbot is installed
Run:
```bash
certbot --version
```

**Scenario A: Certbot is NOT installed**
Install Certbot and the Nginx plugin:
```bash
sudo apt install -y certbot python3-certbot-nginx
```

**Scenario B: Certbot is already installed**
Proceed to generating the certificate.

#### Generate Certificate
Run Certbot to automatically configure SSL:
```bash
sudo certbot --nginx -d jenkins.yourdomain.com
```
Follow the prompts to redirect HTTP traffic to HTTPS.

### Step 4: Final Jenkins Configuration

1.  Log in to Jenkins using your new domain: `https://jenkins.yourdomain.com`.
2.  Go to **Manage Jenkins** -> **System**.
3.  Scroll down to **Jenkins Location**.
4.  Update **Jenkins URL** to `https://jenkins.yourdomain.com/`.
5.  Click **Save**.

## Data Persistence & Management

- **Data Safety**: Jenkins data is stored in a Docker volume named `jenkins-data`. 
- **Stopping Jenkins**:
  ```bash
  docker-compose down
  ```
  *This stops and removes containers but **KEEPS** your data safe in the volume.*

- **Viewing Logs**:
  ```bash
  docker-compose logs -f
  ```

### Optional: Permissions for Docker Pipelines
If your Jenkins jobs need to run Docker commands (e.g., building images), you can mount the host's Docker socket.

**⚠️ Warning:** This grants root-level access to the host.

Update `docker-compose.yml`:
```yaml
services:
  jenkins:
    volumes:
      - jenkins-data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
```
