*This project has been created as part of the 42 curriculum by ajamoun.*

# Inception

## Description

Inception is a system administration project that sets up a small web infrastructure using Docker. It builds three custom Docker images — NGINX, WordPress with PHP-FPM, and MariaDB — each running in its own container, wired together with Docker Compose. The goal is to learn how to containerize services properly instead of relying on ready-made images, and to understand core concepts like volumes, networks, and secrets management.

## Instructions

### Requirements

- Docker and Docker Compose installed
- A `secrets/` folder at the project root containing the required password files (see `DEV_DOC.md`)

### Setup

1. Clone the repository
2. Add `ajamoun.42.fr` to `/etc/hosts`, pointing at `127.0.0.1`
3. Create the secret files in `secrets/` (see `DEV_DOC.md`)
4. Run `make` from the project root

### Usage

Visit `https://ajamoun.42.fr` in a browser (accept the self-signed certificate warning).

See `USER_DOC.md` and `DEV_DOC.md` for full details.

## Resources

- Docker documentation: https://docs.docker.com
- Docker Compose documentation: https://docs.docker.com/compose
- WordPress CLI (wp-cli): https://wp-cli.org
- MariaDB documentation: https://mariadb.com/kb/en/documentation
- NGINX documentation: https://nginx.org/en/docs

**AI usage**: AI was used only as a learning aid, to understand the underlying concepts more clearly (Docker images, layers and containers, volumes and bind mounts, networks and container DNS, secrets, Docker Compose, PHP-FPM, NGINX and TLS). The project's files were written, tested and debugged by me, and I can explain every part of them.

## Project description

### Docker and the project's sources

Each service (NGINX, WordPress+PHP-FPM, MariaDB) is built from its own Dockerfile, based on the penultimate stable version of Debian. No ready-made service images are pulled — only the base OS image comes from Docker Hub. Configuration files and startup scripts for each service live under `srcs/requirements/<service>/`.

### Virtual Machines vs Docker

A virtual machine virtualizes an entire computer, including its own kernel, which makes it heavier and slower to start. A Docker container shares the host machine's kernel and only isolates the application and its dependencies, making it much lighter and faster to start, while still keeping services separated from each other.

### Secrets vs Environment Variables

Environment variables are visible to anyone who can inspect the container (e.g. `docker inspect`), which makes them unsuitable for passwords. Docker secrets are mounted as files inside the container at runtime and are not stored as plain container metadata, which is safer for confidential information like database passwords.

### Docker Network vs Host Network

With `network: host`, a container shares the host's network stack directly, which removes isolation and can create port conflicts. A custom Docker network keeps containers isolated on their own private network, lets them find each other by name through Docker's built-in DNS, and only exposes the ports that are explicitly published.

### Docker Volumes vs Bind Mounts

A bind mount links a container path directly to a specific folder on the host, chosen and managed by the user. A named volume is managed by Docker itself, making it more portable and safer, while still using `driver_opts` to force the folder where the data physically lives when required — as done in this project, under `/home/ajamoun/data`.