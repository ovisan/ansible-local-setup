# Ansible Development Environment Role

This Ansible role sets up a development environment on macOS or Linux systems. It automatically detects the operating system and installs appropriate packages and tools.

## Features

- OS detection between macOS and Linux (Debian/Ubuntu and RedHat/CentOS)
- Common packages installed across all platforms
- OS-specific package installation
- Local execution without requiring a remote server

## Requirements

- Ansible 2.9 or higher
- macOS or Linux (Debian/Ubuntu or RedHat/CentOS)

## Project Structure

```
.
├── setup.sh              # Bootstrap script (installs brew/ansible, runs playbook)
├── local.yml             # Main Ansible playbook
└── roles/dev/
    ├── defaults/
    │   └── main.yml      # Default variables including package lists
    ├── meta/
    │   └── main.yml      # Role metadata
    └── tasks/
        ├── main.yml      # Main tasks file with OS detection
        ├── common.yml    # Common tasks for all platforms
        ├── darwin.yml    # macOS specific tasks
        ├── debian.yml    # Debian/Ubuntu specific tasks
        └── redhat.yml    # RedHat/CentOS specific tasks
```

## Configuration

Edit the `defaults/main.yml` file to customize:

- Common packages installed on all platforms
- OS-specific packages
- Common directories to create
- Git repositories to clone

## Usage

### Quick Start (Recommended)

Simply run the provided setup script. It will automatically install Homebrew (on macOS) and Ansible if they are not already present, then run the playbook:

```bash
./setup.sh
```

The script will prompt for your sudo password when needed.

### Manual Setup

If you already have Ansible installed, you can run the playbook directly:

```bash
ansible-playbook local.yml --ask-become-pass
```

## Customization

You can customize the role by modifying the variables in `defaults/main.yml`:

- `common_packages`: Packages to install on all platforms
- `darwin_packages`: macOS specific packages (via Homebrew)
- `debian_packages`: Debian/Ubuntu specific packages
- `redhat_packages`: RedHat/CentOS specific packages
- `common_directories`: Directories to create
- `common_git_repos`: Git repositories to clone

## License

MIT
