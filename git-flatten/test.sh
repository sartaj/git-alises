#!/bin/bash

# Store the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test suite results tracking
declare -A TEST_RESULTS
TESTS_RUN=0
TESTS_PASSED=0

# Set up test environment
setup_test() {
    # Create temporary directory for remote and local repos
    TEST_DIR=$(mktemp -d)
    REMOTE_DIR="$TEST_DIR/remote.git"
    WORK_DIR="$TEST_DIR/work"

    # Create bare repository (this will be our remote)
    git init --bare --initial-branch=main "$REMOTE_DIR"

    # Create and set up local repository
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    git init -b main
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Add remote
    git remote add origin "$REMOTE_DIR"

    # Create initial commit (main branch)
    echo "initial" > file.txt
    git add file.txt
    git commit -m "Initial commit"
    
    # Push to remote
    git push -u origin main

    # Create feature branch
    git checkout -b feature
    
    # Create multiple commits to flatten
    echo "change 1" >> file.txt
    git add file.txt
    git commit -m "First change"
    
    echo "change 2" >> file.txt
    git add file.txt
    git commit -m "Second change"
    
    echo "change 3" >> file.txt
    git add file.txt
    git commit -m "Third change"
}

# Clean up test environment
cleanup_test() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: Flatten without commit message should use the last commit's message
test_flatten_without_message() {
    local initial_commit_count=$(git rev-list HEAD --count)
    local last_message=$(git log -1 --pretty=%B)
    
    bash "$SCRIPT_DIR/git-flatten.sh"
    
    local status_output=$(git status --short)

    echo "Status output: $status_output"

    # Verify that git status shows M (modified) for file.txt
    [ "$status_output" = "M  file.txt" ]
}

# Test: Flatten with commit message should create a commit
test_flatten_with_message() {
    local initial_commit_count=$(git rev-list HEAD --count)
    
    bash "$SCRIPT_DIR/git-flatten.sh" -m "Flattened commits"
    
    local final_commit_count=$(git rev-list HEAD --count)
    local latest_message=$(git log -1 --pretty=%B)
    
    # Should have one less commit than before (flattened) and message should match
    [ $((initial_commit_count - 2)) -eq $final_commit_count ] && [ "$latest_message" = "Flattened commits" ]
}

# Test: Handling uncommitted changes
test_uncommitted_changes() {
    echo "uncommitted change" >> file.txt
    
    if bash "$SCRIPT_DIR/git-flatten.sh" -m "Should fail" 2>&1 | grep -q "Cannot flatten with uncommitted changes"; then
        return 0
    else
        return 1
    fi
}

# Test runner function
run_test() {
    local test_name=$1
    local test_func=$2

    echo " "
    echo "🧪🧪🧪Start test: $test_name🧪🧪🧪"
    echo " "

    setup_test
    
    if $test_func; then
        TEST_RESULTS["$test_name"]="✅ Passed"
        ((TESTS_PASSED++))
    else
        TEST_RESULTS["$test_name"]="❌ Failed"
    fi
    
    ((TESTS_RUN++))
    cleanup_test

    echo " "
    echo "🧪🧪🧪End test: $test_name🧪🧪🧪"
    echo " "
}


# Print test results
print_results() {
    echo -e "\nTest Results:"
    echo "-------------"
    for test_name in "${!TEST_RESULTS[@]}"; do
        echo "$test_name: ${TEST_RESULTS[$test_name]}"
    done
    echo "-------------"
    echo "Tests run: $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
}

# Main test execution
main() {
    # Run all tests
    run_test "Flatten without commit message" test_flatten_without_message
    run_test "Flatten with commit message" test_flatten_with_message
    run_test "Handling uncommitted changes" test_uncommitted_changes
    
    # Print results
    print_results
    
    # Exit with success if all tests passed
    [ "$TESTS_RUN" -eq "$TESTS_PASSED" ]
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi