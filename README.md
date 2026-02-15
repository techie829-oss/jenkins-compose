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

## Configuration Details

- **Port 8080**: Mapped to the host for accessing the Jenkins UI.
- **Port 50000**: Mapped for inbound Jenkins agent connections.
- **Volume**: A named volume `jenkins-data` is used to persist Jenkins data (`/var/jenkins_home`). This ensures your configuration and build history are saved even if the container is removed.

## Managing the Service

- Stop the service:
  ```bash
  docker-compose down
  ```
- View logs:
  ```bash
  docker-compose logs -f
  ```
