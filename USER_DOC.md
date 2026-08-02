# User Documentation

This guide provides the necessary instructions for end users and administrators to interact with the Inception infrastructure.

### Services Provided by the Stack
This infrastructure provides a secure, fully functional web publishing platform:
*   **Web Server (NGINX):** Secures all incoming connections using TLS (HTTPS) and serves the website content.
*   **Application (WordPress):** A dynamic Content Management System (CMS) allowing administrators to publish articles, manage users, and customize the site.
*   **Database (MariaDB):** An isolated data vault that stores all website content and user accounts.

### How to Start and Stop the Project
The infrastructure is managed entirely through a Makefile located at the root of the repository.

*   **To start the project:** Open a terminal in the root directory and run:
    ```bash
    make up
    ```
*   **To stop the project (keeping data intact):** 
    ```bash
    make down
    ```
*   **To stop the project and wipe all data:** 
    ```bash
    make clean
    ```

### Accessing the Website and Administration Panel
Because the project strictly enforces HTTPS, your browser may display a self-signed certificate warning. You must accept the risk to proceed.

*   **Public Website:** Navigate to `https://obendaou.42.fr`
*   **Administration Panel:** Navigate to `https://obendaou.42.fr/wp-admin`

### Locating and Managing Credentials
For security reasons, credentials are not hardcoded. 
*   **Database & Admin Passwords:** All critical passwords are stored in the `/secrets/` directory at the root of the project. These files are securely injected into the containers at runtime. 
*   **Environment Variables:** General configuration (like domain names and database names) can be viewed or modified in the `.env` file at the root directory.

### Checking that Services are Running Correctly
To verify the health of the infrastructure, run the following command in your terminal:
```bash
docker ps