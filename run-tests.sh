#!/bin/bash

# Test runner script for aidra0

set -e

echo "Running aidra0 unit tests..."
echo "=================================="

# Check if bats is installed
if ! command -v bats &> /dev/null; then
    echo "Error: BATS is not installed. Please install it first."
    echo "Run: git clone https://github.com/bats-core/bats-core.git /tmp/bats-core && cd /tmp/bats-core && sudo ./install.sh /usr/local"
    exit 1
fi

# Run the tests
cd "$(dirname "$0")"

echo "Running tests with BATS..."
echo ""

echo "Running container tests..."
bats tests/test_aidra0.bats

echo ""
echo "Running configuration tests..."
bats tests/test_config.bats

echo ""
echo "Running install script tests..."
bats tests/test_install_simple_mock.bats

echo ""
echo "Test run completed!"
echo ""
echo "To run tests manually:"
echo "  bats tests/test_aidra0.bats"
echo "  bats tests/test_config.bats"
echo "  bats tests/test_install_simple_mock.bats"
echo ""
echo "To run specific test:"
echo "  bats tests/test_aidra0.bats -f 'test name'"
echo "  bats tests/test_config.bats -f 'test name'"
echo "  bats tests/test_install_simple_mock.bats -f 'test name'"
