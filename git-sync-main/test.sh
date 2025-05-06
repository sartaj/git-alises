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
}

# Clean up test environment
cleanup_test() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test that sync-main updates main branch without switching current branch
sync_main_without_switching_branches() {
    # Create and commit a file in main
    echo "initial" > file.txt
    git add file.txt
    git commit -m "Initial commit"
    git push origin main

    # Create and switch to feature branch
    git checkout -b feature
    echo "feature" > feature.txt
    git add feature.txt
    git commit -m "Feature commit"

    # Make a change on main through remote
    git push origin main
    (
        cd "$REMOTE_DIR"
        git worktree add ../temp main
        cd ../temp
        echo "remote change" > remote.txt
        git add remote.txt
        git commit -m "Remote change"
        git push origin main
        cd ..
        rm -rf temp
    )

    # Run git-sync-main
    bash "$SCRIPT_DIR/git-sync-main.sh"

    # Verify we're still on feature branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "feature" ]; then
        echo "❌ Current branch is $current_branch, should be feature"
        return 1
    fi

    # Verify main branch is updated
    git checkout main
    if [ ! -f remote.txt ]; then
        echo "❌ Main branch was not updated with remote changes"
        return 1
    fi

    return 0
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
    run_test sync_main_without_switching_branches

    # Print results
    print_results
    
    # Exit with success if all tests passed
    [ "$TESTS_RUN" -eq "$TESTS_PASSED" ]
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi