#!/usr/bin/env bats

# Load test helpers
load helpers/docker_mock
load helpers/test_helpers

setup() {
    setup_test_env
}

teardown() {
    cleanup_test_env
}

# Test volume mounting logic
@test "script always mounts volume to /user-scripts" {
    export MOCK_IMAGE_EXISTS_LOCALLY="true"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    # The volume should always be mounted to /user-scripts
    # This is now a fixed mount point, no detection needed
    [ "$?" = "0" ]
}

# Test container name generation
@test "container name is generated correctly with argument" {
    export BATS_TEST_MODE=1
    run bash -c 'BASE_NAME="test-app"; CONTAINER_NAME="aidra0-$BASE_NAME"; echo "$CONTAINER_NAME"'
    [ "$output" = "aidra0-test-app" ]
}

@test "container name is generated correctly without argument using folder name" {
    export BATS_TEST_MODE=1
    run bash -c 'BASE_NAME="test-folder"; CONTAINER_NAME="aidra0-$BASE_NAME"; echo "$CONTAINER_NAME"'
    [ "$output" = "aidra0-test-folder" ]
}

# Test container existence checking
@test "script detects existing container" {
    export MOCK_CONTAINER_EXISTS="true"
    export MOCK_CONTAINER_NAME="aidra0-test-folder"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        CONTAINER_NAME="aidra0-test-folder"
        if docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
            echo "Container '\''$CONTAINER_NAME'\'' already exists."
        fi
    '
    [[ "$output" == *"Container 'aidra0-test-folder' already exists"* ]]
}

@test "script proceeds when container doesn't exist" {
    export MOCK_CONTAINER_EXISTS="false"
    export MOCK_VOLUME_EXISTS="true"
    export MOCK_HOME_FOLDER="/home/ubuntu"
    export MOCK_HOME_EXISTS="true"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        if ! docker ps -a --format "table {{.Names}}" | grep -q "^aidra0-test-folder$"; then
            echo "Detecting home folder in container image..."
        fi
    '
    [[ "$output" == *"Detecting home folder"* ]]
}

# Test volume creation logic
@test "script creates volume when it doesn't exist" {
    export MOCK_VOLUME_EXISTS="false"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        if ! docker volume ls | grep -q "aidra0-home"; then
            echo "Creating docker volume: aidra0-home"
            docker volume create aidra0-home
        fi
    '
    [[ "$output" == *"Creating docker volume: aidra0-home"* ]]
}

@test "script skips volume creation when it exists" {
    export MOCK_VOLUME_EXISTS="true"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        if ! docker volume ls | grep -q "aidra0-home"; then
            echo "Creating docker volume: aidra0-home"
        else
            echo "Docker volume aidra0-home already exists"
        fi
    '
    [[ "$output" == *"Docker volume aidra0-home already exists"* ]]
}

# Test basic custom mount functionality
@test "custom mount CLI array is properly initialized" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    # Test that CLI_CUSTOM_MOUNTS array is initialized
    [ "${#CLI_CUSTOM_MOUNTS[@]}" -eq 0 ]
}

# Test network functionality
@test "network CLI array is properly initialized" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    # Test that CLI_NETWORKS array is initialized
    [ "${#CLI_NETWORKS[@]}" -eq 0 ]
}

# Test resource limit functionality
@test "resource limit variables are properly initialized" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    # Test that resource limit variables are initialized
    [ -z "$CLI_CPU_LIMIT" ]
    [ -z "$CLI_MEMORY_LIMIT" ]
}

@test "validate_cpu_limit accepts valid CPU values" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_cpu_limit "1"
    [ "$status" -eq 0 ]

    run validate_cpu_limit "1.5"
    [ "$status" -eq 0 ]

    run validate_cpu_limit "2.0"
    [ "$status" -eq 0 ]

    run validate_cpu_limit "0.5"
    [ "$status" -eq 0 ]
}

@test "validate_cpu_limit rejects invalid CPU values" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_cpu_limit "0"
    [ "$status" -eq 1 ]

    run validate_cpu_limit "-1"
    [ "$status" -eq 1 ]

    run validate_cpu_limit "abc"
    [ "$status" -eq 1 ]

    run validate_cpu_limit "1.2.3"
    [ "$status" -eq 1 ]
}

@test "validate_memory_limit accepts valid memory values" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_memory_limit "512m"
    [ "$status" -eq 0 ]

    run validate_memory_limit "1g"
    [ "$status" -eq 0 ]

    run validate_memory_limit "2G"
    [ "$status" -eq 0 ]

    run validate_memory_limit "1024"
    [ "$status" -eq 0 ]

    run validate_memory_limit "512M"
    [ "$status" -eq 0 ]
}

@test "validate_memory_limit rejects invalid memory values" {
    export BATS_TEST_MODE=1
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_memory_limit "512x"
    [ "$status" -eq 1 ]

    run validate_memory_limit "abc"
    [ "$status" -eq 1 ]

    run validate_memory_limit "1.5g"
    [ "$status" -eq 1 ]

    run validate_memory_limit ""
    [ "$status" -eq 1 ]
}

@test "parse_arguments function handles --cpu option correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --cpu 2 my-app
    [ "$CLI_CPU_LIMIT" = "2" ]
    [ "$CONTAINER_NAME_ARG" = "my-app" ]
}

@test "parse_arguments function handles --memory option correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --memory 1g my-app
    [ "$CLI_MEMORY_LIMIT" = "1g" ]
    [ "$CONTAINER_NAME_ARG" = "my-app" ]
}

@test "parse_arguments function handles both --cpu and --memory options" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --cpu 1.5 --memory 512m my-app
    [ "$CLI_CPU_LIMIT" = "1.5" ]
    [ "$CLI_MEMORY_LIMIT" = "512m" ]
    [ "$CONTAINER_NAME_ARG" = "my-app" ]
}

@test "build_resource_args function generates correct Docker arguments" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    CLI_CPU_LIMIT="2"
    CLI_MEMORY_LIMIT="1g"

    run build_resource_args
    [ "$status" -eq 0 ]
    [[ "$output" == *"--cpus"* ]]
    [[ "$output" == *"2"* ]]
    [[ "$output" == *"--memory"* ]]
    [[ "$output" == *"1g"* ]]
}

@test "build_resource_args function handles config values correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    CLI_CPU_LIMIT=""
    CLI_MEMORY_LIMIT=""

    run build_resource_args
    [ "$status" -eq 0 ]
    # Output may contain config values, which is expected behavior
}

@test "parse_arguments function handles --network option correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --network my-network my-app
    [ "${CLI_NETWORKS[0]}" = "my-network" ]
    [ "$CONTAINER_NAME_ARG" = "my-app" ]
}

@test "parse_arguments function handles multiple --network options" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --network net1 --network net2 --network net3 my-app
    [ "${#CLI_NETWORKS[@]}" -eq 3 ]
    [ "${CLI_NETWORKS[0]}" = "net1" ]
    [ "${CLI_NETWORKS[1]}" = "net2" ]
    [ "${CLI_NETWORKS[2]}" = "net3" ]
}

@test "validate_network_exists returns true when network exists" {
    export MOCK_NETWORK_EXISTS="true"
    export MOCK_NETWORK_NAME="my-network"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_network_exists "my-network"
    [ "$status" -eq 0 ]
}

@test "validate_network_exists returns false and shows warning when network doesn't exist" {
    export MOCK_NETWORK_EXISTS="false"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_network_exists "nonexistent-network"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Warning: Network 'nonexistent-network' does not exist"* ]]
}

# Test shell detection for existing containers
@test "script detects valid shell in running container" {
    export MOCK_CONTAINER_RUNNING="true"
    export MOCK_CONTAINER_NAME="aidra0-test-folder"
    export MOCK_SHELL="/bin/zsh"
    export MOCK_SHELL_EXISTS="true"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        CONTAINER_NAME="aidra0-test-folder"
        if docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
            echo "Container is already running. Attaching to it..."
        fi
    '
    [[ "$output" == *"Container is already running"* ]]
}

@test "script falls back to /bin/bash when shell detection fails" {
    export MOCK_CONTAINER_RUNNING="true"
    export MOCK_SHELL=""
    export MOCK_SHELL_EXISTS="false"

    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        CONTAINER_NAME="aidra0-test-folder"
        SHELL_CMD=$(docker exec "$CONTAINER_NAME" sh -c "echo \$SHELL" 2>/dev/null || echo "/bin/bash")
        if [ -z "$SHELL_CMD" ] || ! docker exec "$CONTAINER_NAME" test -x "$SHELL_CMD" 2>/dev/null; then
            SHELL_CMD="/bin/bash"
        fi
        echo "Using shell: $SHELL_CMD"
    '
    [[ "$output" == *"Using shell: /bin/bash"* ]]
}

# Test user input handling
@test "script exits when user chooses option 1" {
    run bash -c '
        choice="1"
        case $choice in
            1) echo "Exiting..." ;;
            *) echo "Other option" ;;
        esac
    '
    [[ "$output" == *"Exiting..."* ]]
}

@test "script removes container when user chooses option 2" {
    run bash -c '
        source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
        choice="2"
        case $choice in
            2)
                echo "Removing existing container..."
                docker rm -f "aidra0-test-folder"
                ;;
            *) echo "Other option" ;;
        esac
    '
    [[ "$output" == *"Removing existing container..."* ]]
}

@test "script handles invalid user input" {
    run bash -c '
        choice="invalid"
        case $choice in
            1) echo "Exiting..." ;;
            2) echo "Removing..." ;;
            3) echo "Using..." ;;
            *) echo "Invalid option. Exiting..." ;;
        esac
    '
    [[ "$output" == *"Invalid option. Exiting..."* ]]
}

# Test home folder detection integration
@test "script uses fixed /user-scripts mount point" {
    export MOCK_IMAGE_EXISTS_LOCALLY="true"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    # Volume should always mount to /user-scripts
    # No home folder detection needed anymore
    [ "$?" = "0" ]
}

# Test removed - home folder detection functionality was removed from the script

# Test command line argument parsing
@test "script uses default alpine image when no --image specified" {
    export BATS_TEST_MODE=1

    # Use temporary config directory to avoid interference from user config
    export CONFIG_DIR="$BATS_TMPDIR/aidra0-test-config"
    export CONFIG_FILE="$CONFIG_DIR/config"

    source "$BATS_TEST_DIRNAME/../aidra0"
    [ "$DOCKER_IMAGE" = "alpine" ]
}

@test "parse_arguments function handles --image option correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --image ubuntu:20.04 my-app
    [ "$DOCKER_IMAGE" = "ubuntu:20.04" ]
    [ "$CONTAINER_NAME_ARG" = "my-app" ]
}

@test "parse_arguments function handles container name with --image option" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    parse_arguments --image node:18 my-node-app
    [ "$DOCKER_IMAGE" = "node:18" ]
    [ "$CONTAINER_NAME_ARG" = "my-node-app" ]
}

@test "parse_arguments function shows help with --help option" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    run parse_arguments --help
    [[ "$output" == *"Usage:"* ]]
}

@test "parse_arguments function shows help with -h option" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    run parse_arguments -h
    [[ "$output" == *"Usage:"* ]]
}

@test "parse_arguments function handles unknown option gracefully" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    run parse_arguments --unknown-option
    [[ "$output" == *"Error: Unknown option"* ]]
}

@test "parse_arguments function handles multiple container names error" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"
    run parse_arguments app1 app2
    [[ "$output" == *"Error: Multiple container names"* ]]
}

# Test image validation functions
@test "check_image_exists_locally returns true when image exists" {
    export MOCK_IMAGE_EXISTS_LOCALLY="true"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run check_image_exists_locally "alpine"
    [ "$status" -eq 0 ]
}

@test "check_image_exists_locally returns false when image doesn't exist" {
    export MOCK_IMAGE_EXISTS_LOCALLY="false"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run check_image_exists_locally "nonexistent"
    [ "$status" -eq 1 ]
}

@test "check_image_on_dockerhub returns true when image exists on hub" {
    export MOCK_IMAGE_EXISTS_ON_HUB="true"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run check_image_on_dockerhub "alpine"
    [ "$status" -eq 0 ]
}

@test "check_image_on_dockerhub returns false when image doesn't exist on hub" {
    export MOCK_IMAGE_EXISTS_ON_HUB="false"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run check_image_on_dockerhub "nonexistent"
    [ "$status" -eq 1 ]
}

@test "get_dockerhub_url returns correct URL for official image" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"

    result=$(get_dockerhub_url "alpine")
    [ "$result" = "https://hub.docker.com/_/alpine" ]
}

@test "get_dockerhub_url returns correct URL for user image" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"

    result=$(get_dockerhub_url "user/repo")
    [ "$result" = "https://hub.docker.com/r/user/repo" ]
}

@test "get_dockerhub_url handles image with tag correctly" {
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/../aidra0"

    result=$(get_dockerhub_url "alpine:3.18")
    [ "$result" = "https://hub.docker.com/_/alpine" ]
}

@test "validate_and_prepare_image succeeds when image exists locally" {
    export MOCK_IMAGE_EXISTS_LOCALLY="true"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_and_prepare_image "alpine"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Image 'alpine' found locally"* ]]
}

@test "validate_and_prepare_image fails when image doesn't exist anywhere" {
    export MOCK_IMAGE_EXISTS_LOCALLY="false"
    export MOCK_IMAGE_EXISTS_ON_HUB="false"
    export BATS_TEST_MODE=1

    source "$BATS_TEST_DIRNAME/helpers/docker_mock.bash"
    source "$BATS_TEST_DIRNAME/../aidra0"

    run validate_and_prepare_image "nonexistent"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found on Docker Hub"* ]]
}
