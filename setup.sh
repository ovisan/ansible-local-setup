#!/bin/bash
# setup.sh - Bootstrap script to install dependencies and run the Ansible playbook
# This script ensures Homebrew (macOS) and Ansible are installed before running.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cross-shell compatible way to get the directory where this script is located.
# Works when executed via bash, zsh, or sourced.
if [ -n "${BASH_VERSION+x}" ] && [ -n "${BASH_SOURCE[0]+x}" ]; then
    SCRIPT_SOURCE="${BASH_SOURCE[0]}"
else
    SCRIPT_SOURCE="$0"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]] || [[ -f /etc/centos-release ]] || [[ -f /etc/fedora-release ]]; then
        echo "redhat"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Install Homebrew on macOS
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_info "Homebrew is already installed."
        return 0
    fi

    log_warn "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon Macs
    if [[ -d /opt/homebrew/bin ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_info "Homebrew installation complete."
}

# Install Ansible via Homebrew (macOS)
install_ansible_darwin() {
    if command -v ansible-playbook &>/dev/null; then
        log_info "Ansible is already installed."
        return 0
    fi

    log_warn "Ansible not found. Installing Ansible via Homebrew..."
    brew install ansible
    log_info "Ansible installation complete."
}

# Install Ansible via apt (Debian/Ubuntu)
install_ansible_debian() {
    if command -v ansible-playbook &>/dev/null; then
        log_info "Ansible is already installed."
        return 0
    fi

    log_warn "Ansible not found. Installing Ansible via apt..."
    sudo apt-get update
    sudo apt-get install -y ansible
    log_info "Ansible installation complete."
}

# Install Ansible via dnf/yum (RedHat/CentOS/Fedora)
install_ansible_redhat() {
    if command -v ansible-playbook &>/dev/null; then
        log_info "Ansible is already installed."
        return 0
    fi

    log_warn "Ansible not found. Installing Ansible via dnf..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y ansible
    else
        sudo yum install -y ansible
    fi
    log_info "Ansible installation complete."
}

# Run the Ansible playbook
run_playbook() {
    log_info "Running Ansible playbook..."
    cd "$SCRIPT_DIR"
    ansible-playbook local.yml --ask-become-pass
}

main() {
    log_info "Detecting operating system..."
    OS=$(detect_os)
    log_info "Detected OS: $OS"

    case "$OS" in
        darwin)
            install_homebrew
            install_ansible_darwin
            ;;
        debian)
            install_ansible_debian
            ;;
        redhat)
            install_ansible_redhat
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    run_playbook
    log_info "Setup complete!"
}

main "$@"
