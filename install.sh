#!/bin/bash

# aidra0 Installation Script
# Downloads and installs aidra0 to user's local bin directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository information
REPO="farmi-vn/aidra0"
SCRIPT_URL="https://raw.githubusercontent.com/${REPO}/refs/heads/main/aidra0"
SCRIPT_NAME="aidra0"

# Installation variables
INSTALL_DIR=""
CUSTOM_PATH=""

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if a directory is in PATH
is_in_path() {
    local dir="$1"
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Function to find suitable installation directory
find_install_dir() {
    local path_dirs=("$HOME/bin" "$HOME/.local/bin" "$HOME/Scripts" "$HOME/.bin")
    local found_dirs=()
    
    # Check which directories exist and are in PATH
    for dir in "${path_dirs[@]}"; do
        if [[ -d "$dir" ]] && is_in_path "$dir"; then
            found_dirs+=("$dir")
        fi
    done
    
    # If we found directories in PATH, use the first one
    if [[ ${#found_dirs[@]} -gt 0 ]]; then
        echo "${found_dirs[0]}"
        return 0
    fi
    
    # Check for existing directories not in PATH
    for dir in "${path_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            found_dirs+=("$dir")
        fi
    done
    
    # If we found existing directories, use the first one
    if [[ ${#found_dirs[@]} -gt 0 ]]; then
        echo "${found_dirs[0]}"
        return 0
    fi
    
    # Default to ~/.local/bin
    echo "$HOME/.local/bin"
}

# Function to get user confirmation
confirm_installation() {
    local dir="$1"
    local in_path=""
    
    if is_in_path "$dir"; then
        in_path=" (already in PATH)"
    else
        in_path=" (not in PATH - you may need to add it)"
    fi
    
    echo
    print_info "Installation directory: $dir$in_path"
    echo
    
    while true; do
        read -p "Install aidra0 to this location? (Y/n): " -r response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]|"")
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes (y) or no (n)."
                ;;
        esac
    done
}

# Function to get custom installation path
get_custom_path() {
    while true; do
        echo
        read -p "Enter custom installation directory (or press Enter for ~/.local/bin): " -r custom_dir
        
        if [[ -z "$custom_dir" ]]; then
            echo "$HOME/.local/bin"
            return 0
        fi
        
        # Expand tilde
        custom_dir="${custom_dir/#\~/$HOME}"
        
        # Check if path is absolute
        if [[ "$custom_dir" != /* ]]; then
            print_error "Please provide an absolute path (starting with /)"
            continue
        fi
        
        # Check if it's within user's home directory (recommended)
        if [[ "$custom_dir" != "$HOME"* ]]; then
            print_warning "Installing outside your home directory may require different permissions."
            read -p "Continue with $custom_dir? (y/N): " -r response
            case "$response" in
                [Yy]|[Yy][Ee][Ss])
                    echo "$custom_dir"
                    return 0
                    ;;
                *)
                    continue
                    ;;
            esac
        else
            echo "$custom_dir"
            return 0
        fi
    done
}

# Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        print_success "Docker is installed and available"
        return 0
    else
        print_warning "Docker is not installed or not in PATH"
        echo
        echo "aidra0 requires Docker to function. Please install Docker:"
        echo "  • macOS: https://docs.docker.com/desktop/install/mac-install/"
        echo "  • Windows: https://docs.docker.com/desktop/install/windows-install/"
        echo "  • Linux: https://docs.docker.com/engine/install/"
        echo
        return 1
    fi
}

# Function to download and install aidra0
install_aidra0() {
    local install_path="$1"
    local script_path="$install_path/$SCRIPT_NAME"
    
    print_info "Creating installation directory..."
    mkdir -p "$install_path"
    
    print_info "Downloading aidra0 from GitHub..."
    if ! curl -fsSL "$SCRIPT_URL" -o "$script_path"; then
        print_error "Failed to download aidra0 from $SCRIPT_URL"
        print_error "Please check your internet connection and try again."
        exit 1
    fi
    
    print_info "Setting executable permissions..."
    chmod +x "$script_path"
    
    # Verify the download
    if [[ ! -f "$script_path" ]]; then
        print_error "Installation failed: script not found at $script_path"
        exit 1
    fi
    
    # Test the script
    if ! "$script_path" --version &> /dev/null; then
        print_error "Installation failed: downloaded script is not working properly"
        exit 1
    fi
    
    print_success "aidra0 installed successfully to $script_path"
}

# Function to provide post-installation instructions
show_post_install_info() {
    local install_dir="$1"
    
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Installation complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Check if install directory is in PATH
    if is_in_path "$install_dir"; then
        print_success "aidra0 is ready to use! Try: aidra0 --help"
    else
        print_warning "Installation directory is not in your PATH"
        echo
        echo "To use aidra0 from anywhere, add this to your shell profile:"
        echo "  export PATH=\"$install_dir:\$PATH\""
        echo
        echo "For bash, add it to ~/.bashrc or ~/.bash_profile"
        echo "For zsh, add it to ~/.zshrc"
        echo
        echo "Or run directly: $install_dir/aidra0 --help"
    fi
    
    echo
    echo "Quick start:"
    echo "  aidra0 --help              # Show help"
    echo "  aidra0                     # Create container with current folder name"
    echo "  aidra0 my-project          # Create container named 'my-project'"
    echo "  aidra0 --list              # List all containers"
    echo
    echo "Documentation: https://github.com/$REPO"
}

# Main installation function
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "             aidra0 Installation Script"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    print_info "This script will install aidra0 to your local bin directory"
    echo
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --path)
                CUSTOM_PATH="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [--path <directory>] [--help]"
                echo
                echo "Options:"
                echo "  --path <dir>  Install to custom directory"
                echo "  --help        Show this help message"
                echo
                echo "Example:"
                echo "  curl -s https://github.com/$REPO/raw/refs/heads/main/install.sh | bash"
                echo "  curl -s https://github.com/$REPO/raw/refs/heads/main/install.sh | bash -s -- --path ~/my-tools"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Determine installation directory
    if [[ -n "$CUSTOM_PATH" ]]; then
        # Use custom path provided via command line
        INSTALL_DIR="${CUSTOM_PATH/#\~/$HOME}"
        if [[ "$INSTALL_DIR" != /* ]]; then
            print_error "Custom path must be absolute (start with /)"
            exit 1
        fi
        print_info "Using custom installation path: $INSTALL_DIR"
    else
        # Find best installation directory
        INSTALL_DIR=$(find_install_dir)
        
        # Confirm with user
        if ! confirm_installation "$INSTALL_DIR"; then
            INSTALL_DIR=$(get_custom_path)
        fi
    fi
    
    # Check if aidra0 already exists
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        echo
        print_warning "aidra0 is already installed at $INSTALL_DIR/$SCRIPT_NAME"
        
        # Try to get current version
        local current_version=""
        if current_version=$("$INSTALL_DIR/$SCRIPT_NAME" --version 2>/dev/null | head -n1) && [[ -n "$current_version" ]]; then
            print_info "Current version: $current_version"
        else
            print_info "Current version: Unable to determine"
        fi
        
        echo
        while true; do
            read -p "Overwrite existing installation? (y/N): " -r response
            case "$response" in
                [Yy]|[Yy][Ee][Ss])
                    break
                    ;;
                [Nn]|[Nn][Oo]|"")
                    print_info "Installation cancelled"
                    exit 0
                    ;;
                *)
                    echo "Please answer yes (y) or no (n)."
                    ;;
            esac
        done
    fi
    
    # Install aidra0
    install_aidra0 "$INSTALL_DIR"
    
    # Check Docker (non-blocking)
    echo
    print_info "Checking Docker installation..."
    check_docker
    
    # Show post-installation information
    show_post_install_info "$INSTALL_DIR"
}

# Run main function with all arguments
main "$@"