*This project has been created as part of the 42 curriculum by obendaou.*

## Description
Inception is a system administration and infrastructure project that introduces the concepts of containerization using Docker. The goal is to deploy a small, isolated, and secure infrastructure composed of distinct services running in separate containers, all orchestrated via Docker Compose.

This project implements a classic LEMP-like stack (Linux, Nginx, MariaDB, PHP-FPM) to host a fully functional WordPress website. Docker is used to ensure that the environment is reproducible, immutable, and strictly isolated. Each service is built from a custom Alpine/Debian base image (no pre-configured service images like `wordpress:latest` or `nginx:latest` are allowed).

### Architecture & Design Choices
The infrastructure consists of three main containers:
1.  **NGINX:** The sole entry point to the infrastructure, strictly serving traffic over TLS (HTTPS/443).
2.  **WordPress (PHP-FPM):** The application layer, handling dynamic content generation and communicating with the database.
3.  **MariaDB:** The state layer, storing all user and site data, secured and isolated from the public internet.

#### Virtual Machines vs Docker
Virtual Machines virtualize hardware. They require a full, independent Guest Operating System for every instance, making them heavy in terms of RAM and disk space, and slow to boot. Docker virtualizes the OS kernel. Containers share the host machine's Linux kernel but maintain isolated file systems and processes. This makes Docker containers exceptionally fast to start, highly portable, and computationally lightweight.

#### Secrets vs Environment Variables
Environment variables (`.env`) are easily exposed via `docker inspect` or accidentally printed in application stack traces, making them a security risk for sensitive credentials. Docker Secrets securely mount encrypted data directly into the container's file system (typically at `/run/secrets/`) as temporary, in-memory files (tmpfs). This ensures passwords are never permanently written to disk or exposed in the environment array.

#### Docker Network vs Host Network
Using the Host Network binds the container directly to the host machine's network interfaces, removing isolation and creating port conflicts. This project uses a custom Docker Bridge Network. This creates an isolated, internal DNS zone where containers can discover each other securely by their service names (e.g., `mariadb`), while remaining completely invisible to the external internet unless explicitly exposed via port mapping.

#### Docker Volumes vs Bind Mounts
Bind Mounts link a specific path on the host machine directly to a container, which is heavily dependent on the host's exact directory structure and OS. Docker Volumes are fully managed by the Docker Engine. They persist data even when containers are destroyed, abstract away the host's file system permissions, and provide a safer, more portable way to ensure database persistence.

---

## Instructions
To compile and execute the infrastructure:
1. Ensure `make` and `docker` are installed on your host machine.
2. Clone the repository.
3. Add the domain name to your local hosts file: `sudo nano /etc/hosts` and append `127.0.0.1 obendaou.42.fr`.
4. Run `make` at the root of the repository to build and launch the containers in the background.

---

## Resources
*   [Docker Official Documentation](https://docs.docker.com/)
*   [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
*   [NGINX Reverse Proxy Configuration](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)

**AI Usage:**
Large Language Models were utilized during the development phase strictly as architectural troubleshooting and debugging tools. Specific uses included:
*   Diagnosing PID 1 foreground execution rules inside Dockerfiles.
*   Understanding the passive data channel port mechanics of the FTP protocol.