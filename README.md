# ILIAS Docker Development Environment

This setup provides a quick way to get a local ILIAS development environment running using Docker.

> **Important Note:** This repository is designed to manage a single ILIAS instance. To run multiple instances of ILIAS, you must clone this repository into a separate directory for each instance.

## Prerequisites

1.  **Docker and Docker Compose:** Ensure you have Docker and Docker Compose (v2) installed on your system.

2.  **Directory Setup:**
    The `install.sh` script automatically creates the `files` and `logs` directories if they don't exist. It also sets the required ownership (`www-data:www-data`) and permissions.

    *(Note: The `www-data` user and group must exist on your system.)*

3.  **Supported ILIAS Versions:**
    The `versions` directory contains configurations for each supported ILIAS branch. Before running the installation, ensure a subdirectory exists for the branch you wish to install (e.g., `versions/release_9`). This structure allows for different configurations per version.

## Installation

The `install.sh` script automates the entire setup process. Here’s what it does and how to use it.

### Key Features for Developers

*   **Live Code Reloading:** The script clones the ILIAS repository into the `src` directory, which is directly mounted into the web server container. Any code changes you make in `src` are instantly reflected in your running ILIAS instance without needing to rebuild the container.
*   **Debugging Ready:** Xdebug is enabled by default and listens on port `9003`, allowing you to connect a step debugger for easier development.

### How to Run the Installer

The script requires `sudo` privileges to manage directories and permissions. Execute the `install.sh` script from your terminal with the following arguments:

```bash
sudo ./install.sh <project_name> <branch_name> [web_port] [db_port]
```

**Arguments:**
*   `<project_name>`: A unique name for your project (e.g., `myilias`).
*   `<branch_name>`: The ILIAS branch you want to install (e.g., `release_9`).
*   `[web_port]`: (Optional) The local port to access the ILIAS web interface. Defaults to `80`.
*   `[db_port]`: (Optional) The local port for the database. Defaults to `3306`.

### Example Usage

This command sets up a project named `myilias` using the `release_9` branch, with the web server on port `8080` and the database on port `3307`.

```bash
./install.sh myilias release_9 8080 3307
```

> **Note:** While the ports are optional, specifying them is highly encouraged. This allows you to run multiple, different ILIAS versions simultaneously on your local machine without port conflicts.

### Accessing Your ILIAS Instance

Once the script is complete, you can access your ILIAS instance at `http://localhost:<web_port>`.
