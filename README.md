# Jenkins with Docker Compose

This repository contains a simple Docker Compose setup to run Jenkins using the official LTS image. It is based on the [official Jenkins documentation](https://www.jenkins.io/doc/book/installing/docker/).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your machine.
- [Docker Compose](https://docs.docker.com/compose/install/) installed (usually included with Docker Desktop).

## Getting Started

1.  Clone this repository:
    ```bash
    git clone https://github.com/techie829-oss/jenkins-compose.git
    cd jenkins-compose
    ```

2.  Start the Jenkins container in detached mode:
    ```bash
    docker-compose up -d
    ```

## Post-installation Setup

### 1. Unlock Jenkins

When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.

1.  Browse to `http://localhost:8080` and wait until the **Unlock Jenkins** page appears.
2.  Retrieve the initial administrator password from the container logs or by running the following command:
    ```bash
    docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    ```
3.  Copy the password and paste it into the **Administrator password** field.

### 2. Customize Jenkins and Create Admin User

- Select **Install suggested plugins** to get a standard set of plugins.
- Create your first administrator user when prompted.
- Confirm the **Instance Configuration** (URL).

## Production Setup & Best Practices

### 🔐 HTTPS / Reverse Proxy Setup

For production environments, it is highly recommended to run Jenkins behind a reverse proxy like Nginx or Traefik with HTTPS enabled.

#### Nginx Example

1.  Install Nginx and Certbot on your host machine.
2.  Create an Nginx configuration file (e.g., `/etc/nginx/sites-available/jenkins`):

    ```nginx
    server {
        listen 80;
        server_name jenkins.yourdomain.com;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        server_name jenkins.yourdomain.com;

        ssl_certificate /etc/letsencrypt/live/jenkins.yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/jenkins.yourdomain.com/privkey.pem;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```
3.  Replace `jenkins.yourdomain.com` with your actual domain.

### ⚠️ Set Jenkins Root URL

After setting up your reverse proxy and logging in for the first time:

1.  Go to **Manage Jenkins** -> **System**.
2.  Locate the **Jenkins URL** field.
3.  Set it to your public URL (e.g., `https://jenkins.yourdomain.com/`).
4.  Click **Save**.

This ensures that links in emails and notifications point to the correct public address.

## Configuration Details

- **Port 8080**: Mapped to the host for accessing the Jenkins UI.
- **Port 50000**: Mapped for inbound Jenkins agent connections.
- **Volume**: A named volume `jenkins-data` is used to persist Jenkins data (`/var/jenkins_home`).

### 🔁 Optional: Docker in Jenkins Pipelines

If you need to build Docker images within your Jenkins pipelines, you can mount the host's Docker socket. Update your `docker-compose.yml` to include:

```yaml
services:
  jenkins:
    ...
    volumes:
      - jenkins-data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    ...
```

**Note:** This grants the Jenkins container full access to your host's Docker daemon, which has security implications.

## Managing the Service

- **Stop the service**:
  ```bash
  docker-compose down
  ```
  *Note: This removes the containers but preserves the `jenkins-data` volume, so your configuration and build history remain safe.*

- **View logs**:
  ```bash
  docker-compose logs -f
  ```
