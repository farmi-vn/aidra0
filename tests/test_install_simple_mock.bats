#!/usr/bin/env bats

# Load test helpers with simple mocks
load helpers/docker_mock
load helpers/test_helpers
load helpers/install_mock_simple

setup() {
    setup_test_env
    reset_install_mocks
}

teardown() {
    cleanup_test_env
}

@test "simple install mock loads correctly" {
    run echo "simple mock loaded"
    [ "$status" -eq 0 ]
    [ "$output" = "simple mock loaded" ]
}

@test "is_in_path function works with mocked PATH" {
    set_mock_path "/home/user/bin:/usr/local/bin"
    
    run is_in_path "/home/user/bin"
    [ "$status" -eq 0 ]
    
    run is_in_path "/nonexistent"
    [ "$status" -eq 1 ]
}

@test "mock_curl simulates successful download" {
    export MOCK_CURL_SUCCESS="true"
    export MOCK_CURL_CONTENT="test content"
    
    run mock_curl -s "https://example.com/test"
    [ "$status" -eq 0 ]
    [ "$output" = "test content" ]
}

@test "mock_curl simulates failed download" {
    export MOCK_CURL_SUCCESS="false"
    
    run mock_curl -s "https://example.com/test"
    [ "$status" -eq 1 ]
}

@test "mock_command detects docker when installed" {
    export MOCK_DOCKER_INSTALLED="true"
    
    run mock_command -v docker
    [ "$status" -eq 0 ]
    [[ "$output" == *"docker"* ]]
}

@test "mock_command fails when docker not installed" {
    export MOCK_DOCKER_INSTALLED="false"
    
    run mock_command -v docker
    [ "$status" -eq 1 ]
}

@test "install script help works" {
    run bash "$BATS_TEST_DIRNAME/../install.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--path"* ]]
}

@test "install script rejects invalid arguments" {
    run bash "$BATS_TEST_DIRNAME/../install.sh" --invalid
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "install script detects existing installation and shows update message" {
    # Create a temporary test directory and mock script
    local test_dir="$BATS_TMPDIR/test_install"
    mkdir -p "$test_dir"
    
    # Create a mock aidra0 script that responds to --version
    cat > "$test_dir/aidra0" << 'EOF'
#!/bin/bash
if [[ "$1" == "--version" ]]; then
    echo "aidra0 version 1.0.0"
    exit 0
fi
EOF
    chmod +x "$test_dir/aidra0"
    
    # Test that the install script detects existing installation and shows update message
    # We'll interrupt before actual download by making curl fail
    run timeout 5 bash "$BATS_TEST_DIRNAME/../install.sh" --path "$test_dir" || true
    [[ "$output" == *"aidra0 is already installed"* ]]
    [[ "$output" == *"Current version: aidra0 version 1.0.0"* ]]
    [[ "$output" == *"Updating existing installation"* ]]
}

@test "install script handles version detection failure and shows update message" {
    # Create a temporary test directory and broken mock script
    local test_dir="$BATS_TMPDIR/test_install_broken"
    mkdir -p "$test_dir"
    
    # Create a mock aidra0 script that doesn't respond to --version properly
    cat > "$test_dir/aidra0" << 'EOF'
#!/bin/bash
exit 1
EOF
    chmod +x "$test_dir/aidra0"
    
    # Test that the install script handles version detection failure and shows update message
    # We'll interrupt before actual download by making curl fail
    run timeout 5 bash "$BATS_TEST_DIRNAME/../install.sh" --path "$test_dir" || true
    [[ "$output" == *"aidra0 is already installed"* ]]
    [[ "$output" == *"Current version: Unable to determine"* ]]
    [[ "$output" == *"Updating existing installation"* ]]
}