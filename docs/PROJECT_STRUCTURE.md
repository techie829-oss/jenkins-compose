# Project Structure

This document outlines the file organization of the Jenkins Docker Compose repository.

## Core Files

- **`docker-compose.yml`**: Main Docker Compose configuration for running Jenkins.
- **`docker-compose-dind.yml`**: Alternative Docker Compose configuration for Docker-in-Docker (DinD) setup.
- **`Dockerfile`**: Custom Docker image definition based on the official Jenkins LTS image. Primes the image with specific plugins and tools.
- **`.env.example`**: Template for environment variables. Copy to `.env` to configure.

## Scripts

- **`start.sh`**: Automated startup script. Checks requirements, creates `.env`, builds images, and starts Jenkins.
- **`compose.sh`**: Compatibility wrapper for `docker-compose` (V1) and `docker compose` (V2).
- **`backup.sh`**: Script to backup Jenkins data volume to a tarball.
- **`restore.sh`**: Script to restore Jenkins data volume from a backup tarball.

## Documentation (in `docs/`)

- **`README.md`**: Main documentation and quick start guide (in root).
- **`SETUP_OPTIONS.md`**: Comparison and guide for different setup options (Simple vs DinD).
- **`DOMAIN_SETUP.md`**: Detailed guide for setting up a custom domain with Nginx and SSL.
- **`COMPLIANCE_CHECKLIST.md`**: Security and operational checklist for production deployments.
- **`DOCKER_COMPOSE_V2.md`**: Migration guide and differences between Docker Compose V1 and V2.
- **`PROJECT_STRUCTURE.md`**: This file.

## Directories

- **`docs/`**: Documentation files.
