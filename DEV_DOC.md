### DEV_DOC.md

```markdown
# Developer Documentation

This guide is intended for systems engineers and developers who need to provision, debug, or modify the Inception infrastructure.

### Setting Up the Environment from Scratch
Before building the stack, you must configure the local environment:

1.  **Prerequisites:** Ensure Docker, Docker Compose, and Make are installed on the host OS.
2.  **DNS Resolution:** The NGINX container only responds to a specific domain. You must map localhost to the project domain.
    ```bash
    echo "127.0.0.1 obendaou.42.fr" | sudo tee -a /etc/hosts
    ```
3.  **Data Directories:** Create the physical directories on the host machine where the persistent volumes will live (typically `/home/obendaou/data/wordpress` and `/home/obendaou/data/mariadb`).
4.  **Secrets & Configuration:** 
    *   Create a `.env` file at the root of the repository matching the required variables in the `docker-compose.yml`.
    *   Create a `secrets/` directory and populate it with the necessary plain-text password files (e.g., `db_password.txt`, `db_root_password.txt`).

### Building and Launching the Project
The build process is entirely automated via the Makefile.
To build the images from scratch and launch the containers in detached mode, run:
```bash
make all