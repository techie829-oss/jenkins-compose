# Domain Setup Guide

This guide details how to configure a custom domain for your Jenkins instance using Nginx and Let's Encrypt SSL.

## Prerequisites

1.  **A Registered Domain**: You must own a domain (e.g., `example.com`).
2.  **DNS Access**: Ability to add A records.
3.  **Server IP**: The public IP address of your Jenkins server.

## Step 1: Configure DNS

Add an **A Record** in your DNS provider's dashboard:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | `jenkins` | `<your-server-ip>` | 300 (or default) |

*This maps `jenkins.example.com` to your server.*

## Step 2: Install Nginx

Nginx will act as a reverse proxy, handling SSL termination and forwarding traffic to Jenkins.

```bash
sudo apt update
sudo apt install -y nginx
```

## Step 3: Configure Nginx

Create a new configuration file:

```bash
sudo nano /etc/nginx/sites-available/jenkins
```

Paste the following configuration (replace `jenkins.yourdomain.com` with your actual domain):

```nginx
upstream jenkins {
    server 127.0.0.1:8080 fail_timeout=0;
}

server {
    listen 80;
    server_name jenkins.yourdomain.com;

    location / {
        proxy_pass http://jenkins;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (Required for Jenkins Blue Ocean)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Increase timeouts for long-running operations
        proxy_read_timeout 90s;
        proxy_connect_timeout 90s;
        proxy_send_timeout 90s;
        
        # Max upload size (adjust as needed for plugins/artifacts)
        client_max_body_size 50m;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Optional: remove default site
sudo nginx -t
sudo systemctl restart nginx
```

## Step 4: Secure with SSL (Let's Encrypt)

Install Certbot:

```bash
sudo apt install -y certbot python3-certbot-nginx
```

Obtain the certificate:

```bash
sudo certbot --nginx -d jenkins.yourdomain.com
```

- Enter your email when prompted.
- Agree to terms.
- Select **Redirect** (2) to force HTTPS.

## Step 5: Update Jenkins URL

1.  Log in to Jenkins.
2.  Go to **Manage Jenkins** -> **System**.
3.  Scroll to **Jenkins Location**.
4.  Set **Jenkins URL** to `https://jenkins.yourdomain.com/`.
5.  Click **Save**.

Your Jenkins instance is now secure and accessible via your custom domain!
