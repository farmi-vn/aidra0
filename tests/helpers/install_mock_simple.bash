#!/bin/bash

# Simplified install script mock functions for testing

# Global mock state variables
export MOCK_CURL_SUCCESS="true"
export MOCK_CURL_CONTENT="#!/bin/bash\necho 'mock aidra0 script'"
export MOCK_DOCKER_INSTALLED="true"
export MOCK_USER_RESPONSES=""
export MOCK_PATH_DIRS="/usr/local/bin:/usr/bin:/bin"

# Simple function to check if directory is in PATH (matching install script)
is_in_path() {
    local dir="$1"
    case ":$MOCK_PATH_DIRS:" in
        *":$dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Simple mock for curl
mock_curl() {
    if [[ "$MOCK_CURL_SUCCESS" != "true" ]]; then
        return 1
    fi
    
    # If -o flag is present, write to file
    local output_file=""
    local i=1
    for arg in "$@"; do
        if [[ "$arg" == "-o" ]]; then
            # Next argument is the output file
            eval "output_file=\${$((i+1))}"
            break
        fi
        i=$((i+1))
    done
    
    if [[ -n "$output_file" ]]; then
        echo "$MOCK_CURL_CONTENT" > "$output_file"
    else
        echo "$MOCK_CURL_CONTENT"
    fi
    
    return 0
}

# Simple mock for command -v
mock_command() {
    if [[ "$1" == "-v" ]]; then
        local cmd="$2"
        case "$cmd" in
            docker)
                if [[ "$MOCK_DOCKER_INSTALLED" == "true" ]]; then
                    echo "/usr/bin/docker"
                    return 0
                else
                    return 1
                fi
                ;;
            *)
                echo "/usr/bin/$cmd"
                return 0
                ;;
        esac
    else
        builtin command "$@"
    fi
}

# Set up mock responses
set_mock_path() {
    export MOCK_PATH_DIRS="$1"
}

# Reset all mock state
reset_install_mocks() {
    export MOCK_CURL_SUCCESS="true"
    export MOCK_CURL_CONTENT="#!/bin/bash\necho 'mock aidra0 script'"
    export MOCK_DOCKER_INSTALLED="true"
    export MOCK_USER_RESPONSES=""
    export MOCK_PATH_DIRS="/usr/local/bin:/usr/bin:/bin"
}

# Export functions
export -f is_in_path
export -f mock_curl
export -f mock_command
export -f set_mock_path
export -f reset_install_mocks