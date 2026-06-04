# AGENTS.md — Agent Context for ansible-local-setup

> This file is intended for AI coding agents. It assumes the reader knows nothing about the project.

---

## Project Overview

This is a personal **Ansible-based local development environment bootstrapper**. Its sole purpose is to provision a macOS or Linux workstation by installing packages, creating directories, cloning dotfiles, and copying shell configuration files — all from a single local playbook run.

It is **not** a service, library, or application. It is an infrastructure-as-code project meant to be executed directly on the target machine (`localhost`).

**Repository**: `ansible-local-setup`
**Author**: ovisan (inferred from dotfiles repo reference)
**License**: MIT

---

## Technology Stack

| Layer | Technology | Version Requirement |
|-------|-----------|---------------------|
| Automation engine | Ansible | >= 2.9 |
| Bootstrap script | Bash | POSIX-ish (`set -euo pipefail`) |
| Package managers invoked | Homebrew (macOS), `apt` (Debian/Ubuntu), `yum`/`dnf` (RedHat) | — |
| Data format | YAML | — |

No Python package manifests (`requirements.txt`, `pyproject.toml`), no `package.json`, no `Cargo.toml`, and no compiled artifacts exist in this repository.

---

## Project Structure

```
.
├── AGENTS.md                 # This file
├── README.md                 # Human-facing quick-start documentation
├── setup.sh                  # Bash bootstrap entry point
├── local.yml                 # Main Ansible playbook (localhost only)
└── roles/
    └── dev/                  # Single Ansible role — all logic lives here
        ├── defaults/
        │   └── main.yml      # Default variables (package lists, directories, repos)
        ├── meta/
        │   └── main.yml      # Role metadata (author, platforms, license)
        └── tasks/
            ├── main.yml      # Task orchestration & OS dispatch
            ├── common.yml    # Cross-platform tasks (packages, dirs, git clones)
            ├── darwin.yml    # macOS-specific tasks (Homebrew formulas + casks)
            ├── debian.yml    # Debian/Ubuntu-specific tasks (apt)
            └── redhat.yml    # RedHat/CentOS/Fedora-specific tasks (yum/dnf)
```

### File Responsibilities

- **`setup.sh`** — Detects the OS, installs Homebrew (macOS) and Ansible if missing, then executes `ansible-playbook local.yml --ask-become-pass`.
- **`local.yml`** — Playbook that targets `localhost` with `connection: local` and includes the single `dev` role.
- **`roles/dev/defaults/main.yml`** — Source of truth for customization. Defines lists of packages, directories to create, and Git repositories to clone.
- **`roles/dev/tasks/main.yml`** — Includes `common.yml`, copies `.vimrc` and `.zshrc` from the cloned dotfiles repo, then conditionally includes the OS-specific task file (`darwin.yml`, `debian.yml`, `redhat.yml`).
- **`roles/dev/tasks/common.yml`** — Installs `common_packages` using the correct package module per OS, creates `common_directories`, and clones `common_git_repos`.

---

## Runtime Architecture

1. **Bootstrap** (`setup.sh`):
   - OS detection via `$OSTYPE` and `/etc/*-release` files.
   - Installs Homebrew on macOS if absent.
   - Installs Ansible via the native package manager (Homebrew, apt, or dnf/yum).
   - Delegates to `ansible-playbook`.

2. **Playbook Execution** (`local.yml` → `roles/dev`):
   - `gather_facts: true` is required because OS family checks (`ansible_facts['os_family']`) drive task inclusion.
   - The role runs with `become: true` implicitly on Linux tasks that require root.
   - macOS tasks use the `homebrew` / `homebrew_cask` modules and do **not** use `become`.

3. **Idempotency**:
   - All package installation tasks use `state: present`.
   - Directory creation uses `state: directory`.
   - Git clone tasks use `update: true` by default (configurable per repo).

---

## Supported Platforms

| OS Family | Detected By | Package Module |
|-----------|-------------|----------------|
| macOS (Darwin) | `$OSTYPE == darwin*` | `homebrew` / `homebrew_cask` |
| Debian / Ubuntu | `/etc/debian_version` exists | `apt` |
| RedHat / CentOS / Fedora | `/etc/redhat-release`, `/etc/centos-release`, or `/etc/fedora-release` exists | `yum` |

---

## Build and Test Commands

There is **no formal test suite**, **no CI configuration**, and **no build step** in this repository.

### Running the Playbook

**Quick start (recommended):**
```bash
./setup.sh
```

**Manual (if Ansible is already installed):**
```bash
ansible-playbook local.yml --ask-become-pass
```

### Syntax Checking

You can validate the playbook and role syntax without making changes:
```bash
ansible-playbook local.yml --syntax-check
```

### Dry Run

To preview changes:
```bash
ansible-playbook local.yml --ask-become-pass --check --diff
```

> Note: A dry run may produce errors for tasks that depend on prior task results (e.g. copying dotfiles before the repo is cloned).

---

## Code Style Guidelines

- **YAML**: Use 2-space indentation. Start each file with `---`.
- **Bash**: `setup.sh` uses `set -euo pipefail`. Prefer `[[` over `[` for conditionals.
- **Naming**: Variables use snake_case. Lists are plural nouns (`common_packages`, `darwin_casks`).
- **Comments**: Major task blocks have a one-line descriptive comment above them.
- **Conditionals**: Use `when:` clauses on the task level rather than inside Jinja2 expressions where possible.
- **Loops**: Use `loop: "{{ list_var }}"` with `item` as the loop variable.

---

## Customization Conventions

All user-tunable data lives in **`roles/dev/defaults/main.yml`**. Key variables:

- `common_packages` — CLI tools installed on every platform.
- `darwin_packages` / `darwin_casks` — macOS-specific Homebrew formulas and GUI apps.
- `debian_packages` — Debian/Ubuntu-specific apt packages.
- `redhat_packages` — RedHat-family yum/dnf packages.
- `common_directories` — Directories ensured to exist under `$HOME`.
- `common_git_repos` — Repositories cloned before dotfile copying happens.

The playbook currently hard-copies `.vimrc` and `.zshrc` from `~/code/dotfiles/` to `$HOME`. The `when` clause checks that the `ovisan/dotfiles` repo is present in `common_git_repos`.

---

## Security Considerations

- **`--ask-become-pass`**: The playbook prompts for the sudo password at runtime. No credentials are stored in the repository.
- **Homebrew installer**: `setup.sh` and `darwin.yml` fetch and execute the official Homebrew install script via `curl | bash`. This is standard for Homebrew but means execution of remote code.
- **No secrets management**: There are no vaults, encrypted variables, or `.env` files. Do not add secrets to `defaults/main.yml`.
- **Git clones over HTTPS**: Repositories in `common_git_repos` use public HTTPS URLs by default.

---

## Development Workflow

1. Edit variables in `roles/dev/defaults/main.yml` to add/remove packages, directories, or repos.
2. Edit the relevant `tasks/*.yml` file if new task logic is required.
3. Run `./setup.sh` (or `ansible-playbook local.yml --ask-become-pass`) on a target machine to verify.
4. Keep `README.md` in sync with structural or usage changes.

There are no release tags, versioning scripts, or artifact publishing steps.
