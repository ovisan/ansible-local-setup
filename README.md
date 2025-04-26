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

## Role Structure

```
roles/dev/
├── defaults/
│   └── main.yml          # Default variables including package lists
├── meta/
│   └── main.yml          # Role metadata
└── tasks/
    ├── main.yml          # Main tasks file with OS detection
    ├── common.yml        # Common tasks for all platforms
    ├── darwin.yml        # macOS specific tasks
    ├── debian.yml        # Debian/Ubuntu specific tasks
    └── redhat.yml        # RedHat/CentOS specific tasks
```

## Configuration

Edit the `defaults/main.yml` file to customize:

- Common packages installed on all platforms
- OS-specific packages
- Common directories to create
- Git repositories to clone

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/ansible-dev-role.git
   cd ansible-dev-role
   ```

2. Run the playbook locally:
   ```
   ansible-playbook local.yml
   ```

3. To run with sudo privileges (for system-wide installations):
   ```
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
