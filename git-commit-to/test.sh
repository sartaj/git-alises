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

    # Create initial commit
    echo "initial" > file.txt
    git add file.txt
    git commit -m "Initial commit"
    
    # Push to remote and set upstream
    git push -u origin main
}

# Clean up test environment
cleanup_test() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: Basic commit-to functionality
test_basic_commit_to() {
    # Make some changes to test committing to a new branch
    echo "new feature" > feature.txt
    git add feature.txt
    
    # Get current branch name
    local initial_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Try to commit to a new branch
    bash "$SCRIPT_DIR/git-commit-to.sh" feature-branch -m "Test commit"
    
    # Verify we're still on the original branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$initial_branch" != "$current_branch" ]; then
        return 1
    fi
    
    # Verify the new branch exists remotely
    if ! git ls-remote --heads origin feature-branch | grep -q "feature-branch"; then
        return 1
    fi
    
    # Verify the file exists with correct content in the remote branch
    git fetch origin feature-branch
    if ! git show origin/feature-branch:feature.txt | grep -q "new feature"; then
        return 1
    fi
    
    return 0
}

# Test: Handling no staged changes
test_no_staged_changes() {
    # Try to commit without any staged changes
    if bash "$SCRIPT_DIR/git-commit-to.sh" test-branch 2>&1 | grep -q "No staged changes found"; then
        return 0
    else
        return 1
    fi
}

# Test: Custom commit message
test_custom_commit_message() {
    echo "test commit message" > message.txt
    git add message.txt
    
    local test_message="Custom commit message test"
    bash "$SCRIPT_DIR/git-commit-to.sh" message-branch -m "$test_message"
    
    # Fetch and check the commit message
    git fetch origin message-branch
    if git log origin/message-branch -1 --pretty=%B | grep -q "$test_message"; then
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
    run_test "Basic commit-to functionality" test_basic_commit_to
    run_test "Handling no staged changes" test_no_staged_changes
    run_test "Custom commit message" test_custom_commit_message
    
    # Print results
    print_results
    
    # Exit with success if all tests passed
    [ "$TESTS_RUN" -eq "$TESTS_PASSED" ]
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi