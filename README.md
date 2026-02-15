# Jenkins with Docker Compose

This repository contains a Docker Compose setup to run Jenkins using the official LTS image. It includes instructions for setting up a production-ready environment with Nginx and SSL.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- A registered domain name (for production setup)
- Basic knowledge of Linux command line

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/techie829-oss/jenkins-compose.git
   cd jenkins-compose
   ```

2. **Start Jenkins:**
   ```bash
   docker-compose up -d
   ```

3. **Unlock Jenkins:**
   - Browse to `http://localhost:8080` (or `http://<your-server-ip>:8080`)
   - Get the initial password:
     ```bash
     docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
     ```
   - Paste the password to unlock Jenkins
   
4. **Install recommended plugins:**
   - Choose "Install suggested plugins" or select:
     - Git
     - Pipeline
     - Docker Pipeline (if using Docker builds)
     - Blue Ocean (modern UI)
     - Configuration as Code

## Production Setup Guide (Step-by-Step)

This guide assumes you are a **non-root user** with `sudo` privileges.

### Step 1: Verify Initial Access

Before setting up a domain, ensure Jenkins is running and accessible via your server's IP:

`http://<your-server-ip>:8080`

### Step 2: Configure DNS

Add an A record in your DNS provider:

```
Type: A
Name: jenkins (or your chosen subdomain)
Value: <your-server-ip>
TTL: 300 (or provider default)
```

**Verify DNS propagation:**
```bash
nslookup jenkins.yourdomain.com
```

Wait 5-15 minutes for global DNS propagation.

### Step 3: Security Hardening

#### Configure Firewall (UFW)

```bash
# Allow SSH (if not already allowed)
sudo ufw allow 22/tcp

# Allow Nginx HTTP/HTTPS
sudo ufw allow 'Nginx Full'

# Block direct access to Jenkins port
sudo ufw deny 8080/tcp

# Enable firewall
sudo ufw enable
sudo ufw status
```

### Step 4: Nginx Reverse Proxy Setup

#### Check if Nginx is installed

```bash
nginx -v
```

**If NOT installed:**
```bash
sudo apt update
sudo apt install -y nginx
```

#### Configure Nginx

1. Create a configuration file for Jenkins:
   ```bash
   sudo nano /etc/nginx/sites-available/jenkins
   ```

2. Paste the following configuration (replace `jenkins.yourdomain.com`):
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
           
           # WebSocket support for live logs
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           
           # Timeouts for long-running builds
           proxy_read_timeout 300;
           proxy_connect_timeout 300;
       }
   }
   ```

3. Enable the site and restart Nginx:
   ```bash
   sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### Step 5: SSL Setup (Let's Encrypt)

Secure your domain with a free SSL certificate.

#### Check if Certbot is installed

```bash
certbot --version
```

**If NOT installed:**
```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

#### Generate Certificate

```bash
sudo certbot --nginx -d jenkins.yourdomain.com
```

Follow the prompts:
- Enter your email address
- Agree to Terms of Service
- Choose whether to redirect HTTP to HTTPS (recommended: Yes)

**Verify auto-renewal:**
```bash
sudo certbot renew --dry-run
```

**Check renewal timer:**
```bash
sudo systemctl status certbot.timer
```

### Step 6: Final Jenkins Configuration

1. Log in to Jenkins: `https://jenkins.yourdomain.com`
2. Go to **Manage Jenkins** → **System**
3. Scroll to **Jenkins Location**
4. Update **Jenkins URL** to `https://jenkins.yourdomain.com/`
5. Click **Save**

## Data Persistence & Management

### Volume Management

- **Data Location**: Jenkins data is stored in Docker volume `jenkins-data`
- **Safety**: Data persists even when containers are removed

### Common Operations

**Stop Jenkins (keeps data):**
```bash
docker-compose down
```

**Start Jenkins:**
```bash
docker-compose up -d
```

**View logs:**
```bash
docker-compose logs -f jenkins
```

**Restart Jenkins:**
```bash
docker-compose restart jenkins
```

## Docker Integration Options

### Option 1: Docker Socket (Simple but Less Secure)

Mount the host Docker socket to run Docker commands in Jenkins.

**⚠️ WARNING:** This grants Jenkins **root-level access** to your host system.

Update `docker-compose.yml`:
```yaml
services:
  jenkins:
    volumes:
      - jenkins-data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
```

### Option 2: Docker-in-Docker (Recommended for Production)

Use the `docker-compose-dind.yml` file for isolated Docker builds:

```bash
docker-compose -f docker-compose-dind.yml up -d
```

This setup:
- Runs a separate Docker daemon container
- Provides isolation from host
- Uses TLS for secure communication
- Recommended for production environments

## Backup & Recovery

### Create Backup

```bash
# Stop Jenkins gracefully
docker-compose down

# Backup volume to compressed archive
docker run --rm \
  -v jenkins-data:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/jenkins-backup-$(date +%Y%m%d).tar.gz /data

# Restart Jenkins
docker-compose up -d
```

**Schedule automated backups with cron:**
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM (adjust path as needed)
0 2 * * * cd /path/to/jenkins-compose && docker-compose down && docker run --rm -v jenkins-data:/data -v $(pwd):/backup ubuntu tar czf /backup/jenkins-backup-$(date +\%Y\%m\%d).tar.gz /data && docker-compose up -d
```

### Restore from Backup

```bash
# Stop and remove old data
docker-compose down
docker volume rm jenkins-data

# Create fresh volume
docker volume create jenkins-data

# Restore from backup (replace YYYYMMDD with your backup date)
docker run --rm \
  -v jenkins-data:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/jenkins-backup-YYYYMMDD.tar.gz -C /

# Start Jenkins
docker-compose up -d
```

## Updates & Maintenance

### Update Jenkins

```bash
# Backup first!
# See Backup section above

# Pull latest image
docker-compose pull

# Recreate container with new image
docker-compose down
docker-compose up -d
```

### Check Versions

**Current version:**
```bash
docker exec jenkins cat /var/jenkins_home/config.xml | grep '<version>'
```

**Latest LTS version:**
```bash
curl -s https://updates.jenkins.io/current/latest-stable.txt
```

### Plugin Updates

Regularly update plugins through Jenkins UI:
1. Go to **Manage Jenkins** → **Plugins**
2. Click **Available plugins** or **Updates**
3. Select plugins to update
4. Click **Install without restart** or **Download now and install after restart**

## Troubleshooting

### Jenkins appears offline

**Symptom:** Plugins won't install, marketplace unavailable

**Solution:** Add DNS servers to `docker-compose.yml`:
```yaml
services:
  jenkins:
    dns:
      - 8.8.8.8
      - 1.1.1.1
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

### Permission denied errors

**Symptom:** Cannot write to `/var/jenkins_home`

**Solution:** Reset volume permissions:
```bash
docker-compose down
docker volume rm jenkins-data
docker volume create jenkins-data
docker-compose up -d
```

### Nginx 502 Bad Gateway

**Symptom:** Nginx shows error when accessing Jenkins

**Solutions:**
1. Check Jenkins is running:
   ```bash
   docker ps
   ```

2. Check Jenkins logs:
   ```bash
   docker logs jenkins
   ```

3. Verify Jenkins is listening:
   ```bash
   curl http://localhost:8080
   ```

4. Check Nginx configuration:
   ```bash
   sudo nginx -t
   ```

### Container won't start

**Check logs:**
```bash
docker-compose logs jenkins
```

**Common causes:**
- Port 8080 already in use
- Volume permission issues
- Insufficient disk space

**Check port usage:**
```bash
sudo netstat -tulpn | grep 8080
```

### SSL certificate issues

**Check certificate status:**
```bash
sudo certbot certificates
```

**Force renewal:**
```bash
sudo certbot renew --force-renewal
```

### Jenkins performance issues

**Increase Java heap size** in `docker-compose.yml`:
```yaml
environment:
  - JAVA_OPTS=-Xms512m -Xmx2048m -Djenkins.install.runSetupWizard=true
```

Adjust `-Xms` (initial) and `-Xmx` (maximum) based on available RAM.

## Best Practices

### Security

1. **Regular updates:** Keep Jenkins and plugins updated
2. **Strong passwords:** Use complex passwords for admin accounts
3. **Enable CSRF protection:** Enabled by default, don't disable
4. **Restrict script permissions:** Configure "Script Security" plugin
5. **Use credentials plugin:** Store secrets securely
6. **Enable audit logging:** Track user actions
7. **Limit admin access:** Create role-based users

### Performance

1. **Clean old builds:** Configure build retention policies
2. **Use agents:** Offload builds to separate agents
3. **Monitor disk space:** Jenkins can grow large
4. **Limit concurrent builds:** Based on server capacity

### Reliability

1. **Regular backups:** Automated daily backups recommended
2. **Test restores:** Verify backups work periodically
3. **Monitor logs:** Check for errors regularly
4. **Health checks:** Use Docker health checks (included in compose file)

## Configuration as Code (JCasC)

For automated setup, consider using Jenkins Configuration as Code plugin.

**Example `jenkins.yaml`:**
```yaml
jenkins:
  systemMessage: "Jenkins configured automatically by JCasC"
  numExecutors: 2
  
security:
  remotingCLI:
    enabled: false

unclassified:
  location:
    url: "https://jenkins.yourdomain.com/"
```

Mount this in docker-compose:
```yaml
volumes:
  - jenkins-data:/var/jenkins_home
  - ./jenkins.yaml:/var/jenkins_home/jenkins.yaml:ro
environment:
  - CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml
```

## Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Docker Hub](https://hub.docker.com/r/jenkins/jenkins)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues or questions:
- Open an issue on GitHub
- Check Jenkins community forums
- Review documentation links above

---

**Remember:** Always backup your data before making significant changes!
