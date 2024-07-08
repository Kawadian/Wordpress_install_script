## README

## Overview

This shell script is designed to easily install and configure WordPress on an Ubuntu server. During the execution of the script, several prompts will be displayed asking for input. Additionally, an option to enable HTTPS is provided, which will automatically generate a self-signed certificate.

## File Contents

- `install_wordpress.sh`: Shell script for installing and configuring WordPress

## Usage

### Prerequisites

- Ubuntu server set up
- Basic shell access permissions to execute the script

### Steps

1. Make the script executable

```bash
chmod +x install_wordpress.sh
```

2. Run the script

```bash
sudo ./install_wordpress.sh
```

3. Follow the prompts displayed during the execution of the script and enter the required information.

### Input Fields

- **WordPress Directory** (Default: `/srv/www`): Directory to install WordPress
- **Username of Database** (Default: `wordpress`): Database username
- **Password of Database** (blank for random generation): Database password
- **Do you want to enable HTTPS connection?** (y/n): Enable HTTPS connection
- **HTTPS port** (Default: `443`): Port number for HTTPS (if enabled)
- **Do you also enable HTTP connection?** (y/n): Enable HTTP connection as well (if HTTPS is enabled)
- **HTTP port** (Default: `80`): Port number for HTTP

### Information after Installation

After installation, the following information will be displayed:

- Installation directory
- Database username
- Database password
- WordPress URL (HTTP or HTTPS)

An option is also provided to save the installation information as a text file.

### Example

```bash
WordPress has been installed successfully!

---------------------------------
Installation Directory: /srv/www/wordpress
Database Username: wordpress
Database Password: randompassword123
WordPress URL: http://192.168.1.100:80
---------------------------------

Save installation information as a text file? (y/n): y
Installation information has been saved to wordpress_install_info.txt file. Please remove ASAP for security reasons.
```

## Notes

- This script assumes default settings. Modify as needed.
- For security reasons, promptly delete the saved installation information file.
- Exercise caution for security as there may be MySQL root user password or other confidential information during execution.
