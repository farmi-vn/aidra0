# Container Here

Quick create container with auto mount working dir.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Features](#features)
- [Usage](#usage)
- [IDE Integration](#ide-integration)
- [Configuration](#configuration)
- [Resource Management](#resource-management)
- [Command Line Reference](#command-line-reference)
- [Real-World Examples](#real-world-examples)
- [Container Management](#container-management)
- [Image Validation Process](#image-validation-process)
- [Volume Mounting](#volume-mounting)
- [Testing](#testing)
- [Error Handling](#error-handling)
- [Development](#development)

## Requirements

- Docker
- Bash 3.2+
- `curl` (for Docker Hub API checks)
- BATS (for testing, optional)

## Installation

### Quick Install (Recommended)

Install aidra0 with a single command:

```bash
curl https://github.com/farmi-vn/aidra0/raw/refs/heads/main/install.sh | bash
```

This will:
- Download the latest version of aidra0
- Install it to your local bin directory (no sudo required)
- Automatically detect the best installation location in your PATH
- Check for Docker and provide installation guidance if needed

**Custom installation path:**
```bash
curl -s https://github.com/farmi-vn/aidra0/raw/refs/heads/main/install.sh | bash -s -- --path ~/my-tools
```

### Manual Installation

If you prefer to install manually:

1. Clone or download the script
2. Make it executable: `chmod +x aidra0`
3. Move it to where can found by `$PATH`
4. Run: `aidra0 [container-name]`

### Add to PATH (Manual Setup)

For easier access from anywhere:

```bash
# Copy to a directory in your PATH
cp aidra0 $HOME/bin/

# Or create a symlink
sudo ln -s /path/to/aidra0 /usr/local/bin/aidra0

# Now you can run from anywhere
aidra0 --help
```

## Quick Start

```bash
# Create a container with current folder name using default alpine image
./aidra0

# Create a container with custom name
./aidra0 my-project

# Use a specific Docker image
./aidra0 --image ubuntu:22.04 my-ubuntu-project

# Set defaults to avoid typing options every time
./aidra0 --config set default_image ubuntu:22.04
./aidra0 my-project  # Now uses ubuntu:22.04 automatically

# List all your containers to see what's available
./aidra0 --list

# Quickly reconnect to any existing container
./aidra0 --attach my-project
```

## Features

- **🔧 Configuration Management**: Set default Docker images and custom mount paths in `~/.config/aidra0/config`
- **🏷️ Smart Container Naming**: Uses first argument or current folder name with `aidra0-` prefix
- **🐳 Flexible Docker Images**: Specify any Docker image with `--image` option (default: from config or `alpine`)
- **✅ Image Validation**: Automatically checks if images exist locally or on Docker Hub
- **📥 Smart Image Pulling**: Prompts user confirmation before pulling images from Docker Hub
- **💾 Persistent Scripts Volume**: Creates and mounts `aidra0-user-scripts` volume to `/user-scripts`
- **📁 Custom Mount Paths**: Mount host directories with configurable read-only/read-write permissions
- **🌐 Network Connectivity**: Connect containers to Docker networks for service integration
- **🔌 Port Mapping**: Map host ports to container ports for service access
- **🔄 Container Persistence**: Containers persist after exit - no more lost work!
- **📋 Container Management**: List, attach, and manage existing containers easily
- **🔗 Quick Reconnection**: Attach to any existing container with `--attach` command
- **📊 Status Monitoring**: View all containers with their status and mounted directories
- **🐚 Shell Detection**: Automatically detects and uses container's configured shell
- **💻 IDE Integration**: Open VSCode, Cursor connected to containers

## Usage

```bash
# Show help
./aidra0 --help
```

```
Usage: aidra0 [OPTIONS] [CONTAINER_NAME]

Quick create container with auto mount working dir.

Arguments:
  CONTAINER_NAME    Name for the container (default: current folder name)

Options:
  --image IMAGE     Docker image to use (default: from config or alpine)
  --mount PATH      Mount host path to container: /host/path:/container/path[:mode]
                    Mode can be 'rw' (read-write) or 'ro' (read-only). Default: rw
                    Can be used multiple times for multiple mounts
  --mount-ro PATH   Mount host path as read-only: /host/path:/container/path
                    Shorthand for --mount /host/path:/container/path:ro
  --network NAME    Connect container to Docker network (can be used multiple times)
  --port MAPPING    Map host port to container port: host_port:container_port[:protocol]
                    Protocol can be 'tcp' (default), 'udp', or 'sctp'
                    Can be used multiple times for multiple ports
  --cpu NUMBER      Limit CPU usage (e.g., 1, 1.5, 2.0)
  --memory SIZE     Limit memory usage (e.g., 512m, 1g, 2G)
  --list            List all aidra0 containers and their status
  --attach NAME     Attach to existing container by name
  --vscode NAME     Open VSCode connected to container by name
  --cursor NAME     Open Cursor connected to container by name
  --config          Show configuration management options
  view-scripts [OPTIONS]  View content of the scripts volume using temporary container
    --alpine        Force use of Alpine image for viewing scripts
    --image IMAGE   Use specific image for viewing scripts
  -h, --help        Show this help message

Examples:
  aidra0                          # Use current folder name with default image
  aidra0 my-app                   # Use 'my-app' as name with default image
  aidra0 --image ubuntu my-app    # Use ubuntu image with 'my-app' as name
  aidra0 --mount /data:/app/data my-app   # Mount /data to /app/data (read-write)
  aidra0 --mount-ro /config:/app/config my-app # Mount /config to /app/config (read-only)
  aidra0 --mount /data:/data:ro --mount /logs:/logs:rw my-app # Multiple mounts
  aidra0 --network my-network my-app     # Connect to Docker network
  aidra0 --port 8080:80 my-app           # Map host port 8080 to container port 80
  aidra0 --port 8080:80:tcp --port 9090:9090:udp my-app # Multiple port mappings
  aidra0 --cpu 2 --memory 1g my-app      # Limit to 2 CPUs and 1GB memory
  aidra0 --cpu 1.5 my-app                # Limit to 1.5 CPUs
  aidra0 --memory 512m my-app            # Limit to 512MB memory
  aidra0 --list                   # List all aidra0 containers
  aidra0 --attach my-app          # Attach to existing 'my-app' container
  aidra0 --vscode my-app          # Open VSCode connected to 'my-app' container
  aidra0 --cursor my-app          # Open Cursor connected to 'my-app' container
  aidra0 view-scripts             # View content of scripts volume (uses config default or alpine)
  aidra0 view-scripts --alpine   # View scripts using Alpine image
  aidra0 view-scripts --image ubuntu:22.04  # View scripts using Ubuntu image
```

### Basic Usage Examples

```bash
# Use current folder name with default image (alpine or your configured default)
./aidra0

# Specify custom container name with default image
./aidra0 my-app

# Use specific Docker image (overrides default)
./aidra0 --image ubuntu:22.04 my-app

# Use Node.js image with current folder name
./aidra0 --image node:18

# Use Python image for data science work
./aidra0 --image python:3.11-slim data-analysis

# Mount additional directories for data access
./aidra0 --mount /home/user/data:/app/data my-app

# Mount configuration files as read-only
./aidra0 --mount-ro /etc/myconfig:/app/config my-app

# Multiple custom mounts with different permissions
./aidra0 --mount /home/user/data:/app/data:rw --mount-ro /home/user/config:/app/config my-app

# Connect container to Docker network
./aidra0 --network my-network my-app

# Connect to multiple networks
./aidra0 --network frontend --network backend my-app

# Map ports for web development
./aidra0 --port 3000:3000 --port 8080:80 web-app

# Map ports with specific protocols
./aidra0 --port 8080:80:tcp --port 5432:5432:tcp database-app

# List all your containers with their status and directories
./aidra0 --list

# Attach to an existing container (starts if stopped)
./aidra0 --attach my-app

# View scripts volume content
./aidra0 view-scripts
```

## IDE Integration

Container Here provides seamless integration with popular IDEs, allowing you to open your favorite editor directly connected to running containers.

### Supported IDEs

- **VSCode**: Full Dev Containers support with remote development
- **Cursor**: VSCode-based AI editor with container support

### Using IDE Integration

#### VSCode Integration

```bash
# Open VSCode connected to container
./aidra0 --vscode my-app

# Auto-detect container name from current directory
./aidra0 --vscode
```

VSCode will open with the container attached using the Dev Containers extension. The editor will have full access to the container's filesystem and can run commands inside the container.

**Requirements**:

- VSCode installed with `code` command in PATH
- Dev Containers extension installed

#### Cursor Integration

```bash
# Open Cursor connected to container
./aidra0 --cursor my-app

# Auto-detect container name
./aidra0 --cursor
```

Cursor uses the same Dev Containers protocol as VSCode, providing full container integration.

**Requirements**:

- Cursor installed with `cursor` command in PATH
- Dev Containers extension installed

### IDE Workflow Examples

#### Full-Stack Development with VSCode

```bash
# Create frontend container and open in VSCode
./aidra0 --image node:18 frontend
./aidra0 --vscode frontend

# Create backend container and open in another VSCode window
./aidra0 --image python:3.11 backend
./aidra0 --vscode backend
```

#### PHP Development with PHPStorm

```bash
# Create PHP development container
./aidra0 --image php:8.2-cli --port 8080:80 php-app

# Open PHPStorm connected to the container
./aidra0 --phpstorm php-app

# PHPStorm opens with instructions to:
# 1. Configure Docker as remote interpreter
# 2. Set up deployment path mappings
# 3. Enable Docker compose integration
```

#### Quick Editor Switching

```bash
# Start with VSCode
./aidra0 --vscode my-project

# Later, switch to Cursor for AI assistance
./aidra0 --cursor my-project
```

### Technical Details

#### VSCode/Cursor Connection

- Uses the `vscode-remote://attached-container+{HEX_ENCODED_NAME}/app` URI format
- Container name is hex-encoded for URI compatibility
- Automatically starts container if not running

### Adding New IDE Support

The architecture is designed to easily add new IDEs. To add support for a new IDE:

1. Add the CLI option in the argument parser
2. Add a case in the `open_container_with_tool` function
3. Implement the `open_tool_<ide_name>` function

Example for adding IntelliJ IDEA:

```bash
# In the script, you would add:
# 1. --idea option in parse_arguments
# 2. idea) case in open_container_with_tool
# 3. open_tool_jetbrains "idea" function call
```

## Command Line Reference

### Main Options

- `--image IMAGE`: Specify Docker image to use (default: from config or `alpine`)
- `--mount PATH`: Mount host path to container with format `/host/path:/container/path[:mode]`
  - Mode can be `rw` (read-write) or `ro` (read-only)
  - Default mode is `rw` if not specified
  - Can be used multiple times for multiple mounts
- `--mount-ro PATH`: Mount host path as read-only with format `/host/path:/container/path`
  - Shorthand for `--mount /host/path:/container/path:ro`
- `--network NAME`: Connect container to Docker network
  - Can be used multiple times to connect to multiple networks
  - Shows warning if network doesn't exist but continues
- `--port MAPPING`: Map host port to container port with format `host_port:container_port[:protocol]`
  - Protocol can be `tcp` (default), `udp`, or `sctp`
  - Can be used multiple times for multiple port mappings
  - Example: `--port 8080:80` or `--port 8080:80:tcp`
- `--list`: List all aidra0 containers with status and mounted directories
- `--attach NAME`: Attach to existing container by name (starts if stopped)
- `--vscode NAME`: Open VSCode connected to container by name
- `--cursor NAME`: Open Cursor connected to container by name
- `--config`: Show configuration management options or manage settings
- `view-scripts [OPTIONS]`: View content of the scripts volume using temporary container
  - `--alpine`: Force use of Alpine image for viewing scripts
  - `--image IMAGE`: Use specific image for viewing scripts
- `-h, --help`: Show usage information
- `CONTAINER_NAME`: Optional container name (default: current folder name)

### Configuration Commands

- `--config set [--global] <key> <value>`: Set a configuration value (local by default)
- `--config get <key>`: Get a configuration value
- `--config list`: List all configuration values
- `--config which <key>`: Show which config source provides a value
- `--config sources`: List all config sources in precedence order
- `--config`: Show configuration help

## Image Validation Process

The script automatically validates Docker images through the following process:

1. **Local Check**: First checks if the image exists locally
2. **Docker Hub Check**: If not local, queries Docker Hub API to verify existence
3. **User Confirmation**: Shows Docker Hub URL and asks for permission to pull
4. **Automatic Pull**: Downloads the image if user confirms
5. **Error Handling**: Provides clear error messages for non-existent images

### Example Image Validation Flow

```bash
$ ./aidra0 --image python:3.11

Checking Docker image: python:3.11
Image 'python:3.11' not found locally, checking Docker Hub...
✓ Image 'python:3.11' found on Docker Hub
Docker Hub URL: https://hub.docker.com/_/python

Do you want to pull this image? (y/N): y
Pulling image 'python:3.11'...
✓ Image 'python:3.11' pulled successfully
```

## Container Persistence & Management

### Container Persistence

**🎉 New in latest version**: Containers now persist after you exit the shell! No more lost work when you accidentally exit.

- Containers are created **without** the `--rm` flag, so they remain available after exit
- All your work, installed packages, and configurations are preserved
- Simply reconnect to continue where you left off

### Container Management Commands

#### List All Containers

```bash
./aidra0 --list
```

Example output:

```
aidra0 containers:

NAME                    STATUS                  MOUNTED DIRECTORY
my-project             Up 2 hours              /Users/john/projects/my-project
data-analysis          Exited (0) 5 minutes ago /Users/john/data/analysis
web-dev                Up 1 day                /Users/john/sites/webapp

To attach to a container: aidra0 --attach <name>
To create a new container: aidra0 [name]
```

#### Attach to Existing Container

```bash
# Attach to a running container
./aidra0 --attach my-project

# Attach to a stopped container (automatically starts it)
./aidra0 --attach data-analysis
```

### Existing Container Behavior

When a container with the same name already exists, you'll be prompted with options:

1. **Exit** - Stop the script
2. **Remove old container** - Delete existing container and create new one
3. **Use existing container** - Start/attach to existing container (shows current status)

## Configuration

Container Here supports multi-level configuration with clear precedence rules, allowing both project-specific and user-wide settings.

### Configuration Hierarchy (Highest to Lowest Priority)

1. **Command-line arguments** - Override all configurations
2. **Environment variables** - Runtime overrides (e.g., `AIDRA0__DEFAULT_IMAGE`)
3. **Local project config** - `.aidra0.conf` in current directory
4. **Global/User config** - `~/.config/aidra0/config`
5. **Built-in defaults** - Hardcoded fallback values

### Configuration Management

```bash
# Show configuration help
./aidra0 --config
```

```
Configuration Management:

Commands:
  aidra0 --config set [--global] <key> <value>    Set a configuration value
  aidra0 --config get <key>                       Get a configuration value
  aidra0 --config list                            List all configuration values
  aidra0 --config which <key>                     Show which config source provides a value
  aidra0 --config sources                         List all config sources in precedence order

Configuration keys:
  default_image              Default Docker image to use (default: alpine)
  custom_mounts              Custom mount definitions in JSON format
                            Format: [{"host":"/path","container":"/path","mode":"rw|ro"}]
  port_mappings              Port mapping definitions (simple or JSON format)
                            Simple: '8080:80 9090:90:udp'
                            JSON: '[{"host":"8080","container":"80","protocol":"tcp"}]'

Examples:
  # Set local project config (default)
  aidra0 --config set default_image node:18

  # Set global/user config
  aidra0 --config set --global default_image ubuntu:22.04

  # Check which config provides a value
  aidra0 --config which default_image

  # Set port mappings (simple format)
  aidra0 --config set port_mappings '8080:80 9090:90:udp'

  # Override with environment variable
  AIDRA0__DEFAULT_IMAGE=python:3.11 aidra0
```

#### Configuration Commands

```bash
# Set local project config (default behavior like git)
./aidra0 --config set default_image node:18

# Set global/user config (requires --global flag)
./aidra0 --config set --global default_image ubuntu:22.04

# Get current value (from any source)
./aidra0 --config get default_image

# Check which config source provides a value
./aidra0 --config which default_image
# Output: default_image = node:18
#         Source: local (/path/to/project/.aidra0.conf)

# List all configuration sources
./aidra0 --config sources

# List all configuration values with their sources
./aidra0 --config list
```

### Environment Variables

Override any configuration value using environment variables:

```bash
# Override default image
AIDRA0__DEFAULT_IMAGE=python:3.11 ./aidra0 my-app

# Override custom mounts
AIDRA0__CUSTOM_MOUNTS='[{"host":"/tmp","container":"/tmp","mode":"rw"}]' ./aidra0
```

### Local Project Configuration

Create a `.aidra0.conf` file in your project root for project-specific settings:

```bash
# .aidra0.conf
default_image=node:18-alpine
custom_mounts=[{"host":"./src","container":"/app/src","mode":"rw"},{"host":"./config","container":"/app/config","mode":"ro"}]
```

This file can be committed to version control, allowing team members to share the same container configuration.

### Available Configuration Keys

- `default_image`: Default Docker image to use (default: `alpine`)
- `custom_mounts`: Custom mount definitions in JSON format for persistent mount configurations
- `port_mappings`: Port mapping definitions in simple or JSON format for persistent port configurations
- `cpu_limit`: Default CPU limit for containers (e.g., `1`, `1.5`, `2.0`)
- `memory_limit`: Default memory limit for containers (e.g., `512m`, `1g`, `2G`)

### Volume Mounting

Container Here automatically mounts:

- Current working directory to `/app` in the container (read-write)
- Persistent volume `aidra0-user-scripts` to `/user-scripts` for storing scripts and data across container sessions (read-write)

Additionally, you can configure custom mounts:

- **Via CLI flags**: Use `--mount` and `--mount-ro` flags for one-time custom mounts
- **Via configuration**: Set persistent custom mounts using the `custom_mounts` configuration key
- **Mount modes**: Support for both read-write (`rw`) and read-only (`ro`) permissions
- **Path validation**: Automatic validation of host paths (must exist) and container paths (must be absolute)

### Configuration File Format

The configuration file uses a simple `key=value` format:

```
default_image=ubuntu:22.04
custom_mounts=[{"host":"/home/user/data","container":"/app/data","mode":"rw"},{"host":"/etc/configs","container":"/app/config","mode":"ro"}]
```

### Configuration Workflow Examples

#### Multi-Level Configuration Example

```bash
# 1. Set global/user-wide defaults
./aidra0 --config set --global default_image ubuntu:22.04
./aidra0 --config set --global custom_mounts '[{"host":"/home/user/data","container":"/data","mode":"rw"}]'

# 2. Set project-specific overrides (default behavior)
cd /path/to/nodejs-project
./aidra0 --config set default_image node:18-alpine
./aidra0 --config set custom_mounts '[{"host":"./src","container":"/app/src","mode":"rw"}]'

# 3. Check which configuration is active
./aidra0 --config which default_image
# Output: default_image = node:18-alpine
#         Source: local (/path/to/nodejs-project/.aidra0.conf)

# 4. List all configurations with sources
./aidra0 --config list
# Output shows both local and global configs with source indicators

# 5. Override with environment variable for one-off use
AIDRA0__DEFAULT_IMAGE=python:3.11 ./aidra0 test-python

# 6. View configuration hierarchy
./aidra0 --config sources
```

#### Team Collaboration Example

```bash
# Project lead sets up local config
echo 'default_image=node:18-alpine' > .aidra0.conf
echo 'custom_mounts=[{"host":"./src","container":"/app/src","mode":"rw"}]' >> .aidra0.conf

# Commit to version control
git add .aidra0.conf
git commit -m "Add container configuration for team"

# Team members automatically get the same environment
git pull
./aidra0 dev-env    # Uses project-specific configuration
```

## Resource Management

Container Here supports CPU and memory resource limits to control container resource usage and ensure predictable performance.

### Resource Configuration Options

#### CLI Resource Flags

```bash
# Limit CPU usage to 2 cores
./aidra0 --cpu 2 my-app

# Limit memory to 1GB
./aidra0 --memory 1g my-app

# Combine CPU and memory limits
./aidra0 --cpu 1.5 --memory 512m my-app

# Use fractional CPU limits
./aidra0 --cpu 0.5 my-app  # Half CPU core
```

#### Configuration-Based Resource Limits

Set persistent resource limits using the configuration system:

```bash
# Set default CPU limit for all containers
./aidra0 --config set cpu_limit 2.0

# Set default memory limit for all containers
./aidra0 --config set memory_limit 1g

# Set global defaults
./aidra0 --config set --global cpu_limit 1.5
./aidra0 --config set --global memory_limit 2g

# View current resource configuration
./aidra0 --config list
```

#### Environment Variable Overrides

```bash
# Override resource limits with environment variables
AIDRA0__CPU_LIMIT=3 ./aidra0 my-app
AIDRA0__MEMORY_LIMIT=2g ./aidra0 my-app
```

### Resource Limit Formats

#### CPU Limits

- Integer values: `1`, `2`, `4` (number of CPU cores)
- Decimal values: `0.5`, `1.5`, `2.5` (fractional CPU cores)
- Docker equivalent: `--cpus` flag

#### Memory Limits

- Numbers with units: `512m`, `1g`, `2G`, `1024M`
- Raw numbers: `1073741824` (bytes)
- Supported units: `b` (bytes), `k` (KB), `m` (MB), `g` (GB)
- Docker equivalent: `--memory` flag

### Configuration Hierarchy

Resource limits follow the same configuration hierarchy as other settings:

1. **CLI arguments** (`--cpu`, `--memory`) - highest priority
2. **Environment variables** (`AIDRA0__CPU_LIMIT`, `AIDRA0__MEMORY_LIMIT`)
3. **Local project config** (`.aidra0.conf`)
4. **Global user config** (`~/.config/aidra0/config`)
5. **No limits** (default behavior)

### Resource Management Examples

#### Development Environment with Resource Limits

```bash
# Set up a resource-constrained development environment
./aidra0 --config set cpu_limit 1.5
./aidra0 --config set memory_limit 1g
./aidra0 --config set default_image node:18

# All containers will now use these resource limits
./aidra0 frontend-app    # Uses 1.5 CPU, 1GB memory
./aidra0 backend-api     # Uses 1.5 CPU, 1GB memory

# Override for specific containers
./aidra0 --cpu 2 --memory 2g build-server
```

#### Team Configuration for Consistent Resource Usage

```bash
# Project lead sets up resource constraints
echo 'cpu_limit=1.5' > .aidra0.conf
echo 'memory_limit=1g' >> .aidra0.conf
echo 'default_image=node:18-alpine' >> .aidra0.conf

# Commit to version control
git add .aidra0.conf
git commit -m "Add resource limits for consistent development environment"

# Team members get consistent resource usage
git pull
./aidra0 dev-env  # Automatically applies CPU and memory limits
```

## Port Mapping

Container Here supports comprehensive port mapping to expose container services to the host system. Port mappings can be configured via CLI arguments or persistent configuration.

### Port Mapping Options

#### CLI Port Mapping

```bash
# Map single port (TCP is default)
./aidra0 --port 8080:80 web-app

# Map multiple ports
./aidra0 --port 8080:80 --port 3000:3000 web-app

# Specify protocols explicitly
./aidra0 --port 8080:80:tcp --port 9090:9090:udp app

# Database port mapping
./aidra0 --port 5432:5432 database-container
```

#### Configuration-Based Port Mapping

Set persistent port mappings using the configuration system:

```bash
# Simple format (recommended)
./aidra0 --config set port_mappings '8080:80 3000:3000'

# Multiple ports with different protocols
./aidra0 --config set port_mappings '8080:80:tcp 9090:9090:udp'

# JSON format (for complex scenarios)
./aidra0 --config set port_mappings '[
  {"host":"8080","container":"80","protocol":"tcp"},
  {"host":"9090","container":"9090","protocol":"udp"}
]'

# View current port configuration
./aidra0 --config list
```

#### Environment Variable Overrides

```bash
# Override port mappings with environment variables
AIDRA0__PORT_MAPPINGS='3000:3000 8080:80' ./aidra0 my-app
```

### Port Mapping Formats

#### Simple Format (Recommended)

- Space-separated port mappings: `8080:80 9090:90:udp`
- Format: `host_port:container_port[:protocol]`
- Default protocol: `tcp`
- Easier to type and read

#### JSON Format

- Full JSON array: `[{"host":"8080","container":"80","protocol":"tcp"}]`
- More verbose but supports all features
- Backward compatibility maintained

### Supported Protocols

- `tcp` (default) - Transmission Control Protocol
- `udp` - User Datagram Protocol
- `sctp` - Stream Control Transmission Protocol

### Port Mapping Examples

#### Web Development Environment

```bash
# Frontend and backend development
./aidra0 --config set port_mappings '3000:3000 8080:80 5432:5432'
./aidra0 --config set default_image node:18

# All web containers get these ports
./aidra0 frontend-app     # Ports 3000, 8080, 5432 mapped
./aidra0 backend-api      # Same ports automatically mapped

# Override for specific containers
./aidra0 --port 9000:9000 special-service
```

#### Database Services

```bash
# PostgreSQL container
./aidra0 --port 5432:5432 --image postgres:15 database

# Redis container with different host port
./aidra0 --port 6380:6379 --image redis:alpine cache

# Multiple database instances
./aidra0 --port 5433:5432 postgres-test
./aidra0 --port 5434:5432 postgres-staging
```

#### Microservices Architecture

```bash
# Set up port mappings for microservices
./aidra0 --config set port_mappings '8001:8000 8002:8000 8003:8000'

# Each service gets its own port
./aidra0 --port 8001:8000 user-service
./aidra0 --port 8002:8000 order-service
./aidra0 --port 8003:8000 payment-service
```

### Configuration Hierarchy

Port mappings follow the same configuration hierarchy as other settings:

1. **CLI arguments** (`--port`) - highest priority
2. **Environment variables** (`AIDRA0__PORT_MAPPINGS`)
3. **Local project config** (`.aidra0.conf`)
4. **Global user config** (`~/.config/aidra0/config`)
5. **No port mappings** (default behavior)

### Team Configuration Example

```bash
# Project lead sets up port mappings for team
echo 'port_mappings=3000:3000 8080:80' > .aidra0.conf
echo 'default_image=node:18-alpine' >> .aidra0.conf

# Commit to version control
git add .aidra0.conf
git commit -m "Add port mapping configuration for team"

# Team members get consistent port mappings
git pull
./aidra0 dev-env  # Automatically maps ports 3000 and 8080
```

## Volume Mounting

### Default Mounts

- Current directory → `/app` (in container, read-write)
- `aidra0-user-scripts` volume → `/user-scripts` (in container, read-write)

### Custom Mount Options

#### CLI Mount Flags

```bash
# Mount directory with read-write access
./aidra0 --mount /host/data:/container/data my-app

# Mount directory as read-only
./aidra0 --mount-ro /host/configs:/container/configs my-app

# Multiple mounts with mixed permissions
./aidra0 --mount /data:/app/data:rw --mount-ro /configs:/app/config my-app
```

#### Configuration-Based Mounts

```bash
# Set persistent custom mounts
./aidra0 --config set custom_mounts '[
  {"host":"/home/user/projects","container":"/workspace","mode":"rw"},
  {"host":"/etc/ssl/certs","container":"/app/certs","mode":"ro"}
]'

# All future containers will use these mounts automatically
./aidra0 my-project
```

#### Mount Validation

- **Host paths**: Must exist on the host system
- **Container paths**: Must be absolute paths (start with `/`)
- **Mount modes**: Only `rw` (read-write) and `ro` (read-only) are supported
- **CLI override**: CLI mount flags override configuration-based mounts

## Testing

The project includes comprehensive unit tests using BATS (Bash Automated Testing System).

### Running Tests

```bash
# Run all tests
./run-tests.sh

# Run specific test
bats tests/test_AIDRA0_.bats -f "test name"
```

### Test Coverage

- ✅ Volume mounting logic
- ✅ Custom mount path functionality
- ✅ Container name generation
- ✅ Container existence checking
- ✅ Volume creation logic
- ✅ User input handling
- ✅ Shell detection for existing containers
- ✅ Command line argument parsing (`--image`, `--mount`, `--mount-ro`, `--help`)
- ✅ Error handling for invalid options
- ✅ Image validation (local and Docker Hub checks)
- ✅ Docker Hub URL generation
- ✅ Image pulling functionality
- ✅ Mount validation and configuration parsing

### Test Structure

```
tests/
├── test_aidra0.bats          # Main test suite
├── helpers/
│   ├── docker_mock.bash             # Docker command mocks
│   └── test_helpers.bash            # Common test utilities
└── fixtures/
    ├── mock_containers.txt          # Sample docker ps output
    └── mock_volumes.txt             # Sample docker volume ls output
```

## Real-World Examples

### Quick Start (Default Alpine)

```bash
# Start with default alpine image
./aidra0                    # Creates aidra0-<current-folder>
./aidra0 my-tools           # Creates aidra0-my-tools
```

### Development Workflows

#### Web Development Setup

```bash
# Set Node.js as your default for web projects
./aidra0 --config set default_image node:18-alpine

# Set up common web development ports
./aidra0 --config set port_mappings '3000:3000 8080:80 9000:9000'

# Now create containers for different projects
./aidra0 frontend-app       # Uses node:18-alpine with ports mapped
./aidra0 api-server         # Uses node:18-alpine with ports mapped
./aidra0 --image nginx web-proxy  # Override for specific needs

# Create containers with specific port mappings
./aidra0 --port 3001:3000 --port 8081:80 frontend-alt
```

#### Data Science Workflow

```bash
# Set Python as default for data work
./aidra0 --config set default_image python:3.11-slim

# Set up persistent mounts for data and notebooks
./aidra0 --config set custom_mounts '[
  {"host":"/home/user/datasets","container":"/data","mode":"ro"},
  {"host":"/home/user/notebooks","container":"/notebooks","mode":"rw"}
]'

# Create containers for different analyses
./aidra0 data-analysis      # Uses python:3.11-slim with data mounts
./aidra0 ml-experiments     # Uses python:3.11-slim with data mounts

# Override with specific mounts for special projects
./aidra0 --mount /home/user/large-dataset:/data:ro --image jupyter/scipy-notebook research
```

#### DevOps and System Administration

```bash
# Set Ubuntu as default for system work
./aidra0 --config set default_image ubuntu:22.04

# Mount common configuration directories
./aidra0 --mount-ro /etc/ssl:/etc/ssl --mount /var/log:/logs server-config

# Quick debugging with minimal tools
./aidra0 --image alpine:latest --mount-ro /etc/hosts:/etc/hosts minimal-debug

# Container with access to Docker socket (for Docker-in-Docker workflows)
./aidra0 --mount /var/run/docker.sock:/var/run/docker.sock:rw docker-tools
```

### Multi-Language Development

```bash
# Switch defaults as needed
./aidra0 --config set default_image python:3.11
./aidra0 python-api

./aidra0 --config set default_image node:18
./aidra0 react-frontend

./aidra0 --config set default_image golang:1.21
./aidra0 go-microservice

# Or override without changing defaults
./aidra0 --image rust:1.75 rust-project
./aidra0 --image openjdk:17 java-app
```

### Persistent Workflow Examples

#### Daily Development Routine

```bash
# Monday: Start new project
./aidra0 --image node:18 new-app
# Install dependencies, write code, exit accidentally...

# Tuesday: Continue where you left off
./aidra0 --list
# Shows: new-app | Exited (0) 16 hours ago | /Users/you/projects/new-app
./aidra0 --attach new-app
# Back to your environment with all packages still installed!

# Wednesday: Check all active projects
./aidra0 --list
# Shows all containers with their directories and status
```

#### Project Switching

```bash
# Work on frontend (React)
./aidra0 --attach frontend-app
# Work for a while, then switch to backend

# Switch to backend API (Python)
./aidra0 --attach api-server
# Both environments stay ready with all your work preserved

# Quick status check
./aidra0 --list
# See which projects are running vs stopped
```

#### Long-Running Development

```bash
# Start development environment
./aidra0 --image ubuntu:22.04 dev-environment
# Install tools, configure environment, set up dotfiles...

# Weeks later, instantly return to configured environment
./aidra0 --attach dev-environment
# Everything exactly as you left it - no setup needed!
```

### Database and Services

```bash
# Using specialized images with port mappings (will prompt to pull if not local)
./aidra0 --port 5432:5432 --image postgres:15 database-work
./aidra0 --port 6379:6379 --image redis:alpine cache-testing
./aidra0 --port 27017:27017 --image mongo:6 document-db
./aidra0 --port 80:80 --port 443:443 --image nginx:alpine web-server

# Multiple database instances with different host ports
./aidra0 --port 5433:5432 --image postgres:15 postgres-test
./aidra0 --port 5434:5432 --image postgres:15 postgres-prod
```

## Custom Mount Path Examples

### Development Environment Setup

```bash
# Mount source code, build artifacts, and configuration
./aidra0 \
  --mount /home/user/projects:/workspace:rw \
  --mount-ro /home/user/.gitconfig:/root/.gitconfig \
  --mount /home/user/.ssh:/root/.ssh:ro \
  --image ubuntu:22.04 dev-env
```

### Database Container with Persistent Data

```bash
# Mount database data directory and config files
./aidra0 \
  --mount /var/lib/mysql:/var/lib/mysql:rw \
  --mount-ro /etc/mysql/my.cnf:/etc/mysql/my.cnf \
  --image mysql:8.0 database
```

### Web Server with Content and Logs

```bash
# Mount web content as read-only, logs as read-write
./aidra0 \
  --mount-ro /home/user/website:/var/www/html \
  --mount /var/log/nginx:/var/log/nginx:rw \
  --image nginx:alpine web-server
```

### Data Processing Pipeline

```bash
# Mount input data as read-only, output directory as read-write
./aidra0 \
  --mount-ro /data/input:/app/input \
  --mount /data/output:/app/output:rw \
  --mount-ro /config/pipeline.yaml:/app/config.yaml \
  --image python:3.11 data-processor
```

### Configuration-Based Persistent Setup

```bash
# Set up a development environment with persistent mounts
./aidra0 --config set custom_mounts '[
  {"host":"/home/user/projects","container":"/workspace","mode":"rw"},
  {"host":"/home/user/.gitconfig","container":"/root/.gitconfig","mode":"ro"},
  {"host":"/home/user/.ssh","container":"/root/.ssh","mode":"ro"},
  {"host":"/home/user/bin","container":"/usr/local/bin","mode":"ro"}
]'

# Now all containers automatically get these mounts
./aidra0 my-project      # Automatically includes all configured mounts
./aidra0 another-project # Same persistent mounts applied
```

## Error Handling

The script provides helpful error messages for common issues:

- **Invalid image names**: Clear error with suggestion to check Docker Hub
- **Network issues**: Graceful handling of Docker Hub API failures
- **Pull failures**: Informative messages when image downloads fail
- **User cancellation**: Respectful handling when user declines to pull images

## Development

The script is designed to be testable and maintainable:

- Functions are separated for easy testing
- Docker commands are mockable for unit tests
- Test mode prevents script execution during testing
- Comprehensive error handling and user feedback

### Version Management

The project includes a Makefile for version management and development workflows:

```bash
# Show current version
make version

# Bump version (patch, minor, major)
make bump-patch    # 1.0.0 -> 1.0.1
make bump-minor    # 1.0.0 -> 1.1.0
make bump-major    # 1.0.0 -> 2.0.0

# Create release with git tag
make release

# Development commands
make test          # Run tests
make install       # Install to /usr/local/bin
make status        # Show git status and version info
make clean         # Clean up backup files
```

### Auto-Update Feature

aidra0 includes an auto-update feature that checks for new versions:

```bash
# Check current version
aidra0 --version

# Manual upgrade
aidra0 --upgrade

# Skip auto-check for this run
aidra0 --no-check

# Disable auto-check globally
aidra0 --config set auto_check_updates false
```

The auto-update feature:

- Checks for updates once per day (rate limited)
- Shows non-intrusive notifications when updates are available
- Provides safe upgrade process with automatic backup
- Can be disabled via configuration
