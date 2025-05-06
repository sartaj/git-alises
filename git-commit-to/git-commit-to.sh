#!/bin/bash

# git commit-to - Push staged changes to a new branch without switching branches
#
# USAGE:
#   git commit-to <branch-name> [-m <commit-message>]
#
# OPTIONS:
#   -m, --message    Specify a commit message (default: 'update')
#
# EXAMPLES:
#   git commit-to feature-123                     # Create branch 'feature-123' with default commit message
#   git commit-to bugfix -m 'Fix memory leak'     # Create branch 'bugfix' with custom commit message
#
# DESCRIPTION:
#   Creates a new branch from the default base branch (main/master), applies your
#   staged changes to it, and pushes it to the remote repository. All of this is
#   done without switching your current working branch.

# Function to detect the default base branch name
get_default_base_branch() {
    # Get the origin name - try to find "origin" or use the first remote if not found
    local ORIGIN_NAME=$(git remote | grep -m 1 origin || git remote | head -n 1)
    # Get the full head reference
    local HEAD_REF=$(set -- `git ls-remote --symref $ORIGIN_NAME HEAD` && test $1 = ref: && echo $2)
    # Derive the branch name by removing the "refs/heads/" prefix
    local GIT_DEFAULT_BASE_BRANCH=${HEAD_REF#refs/heads/}
    # Determine the base branch to use
    echo "${GIT_DEFAULT_BASE_BRANCH:-master}"
}

# Function to push staged changes to a new branch without switching branches
git_commit_staged_to() {
    ##
    ## Parse Args
    ##

    # Defaults
    local COMMIT_MESSAGE="update"
    local NEW_BRANCH_NAME=""
    local BASE_BRANCH=$(get_default_base_branch)
    local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--message)
                COMMIT_MESSAGE="$2"
                shift 2
                ;;
            *)
                if [[ -z "$NEW_BRANCH_NAME" ]]; then
                    NEW_BRANCH_NAME="$1"
                    shift
                else
                    echo "Error: Unknown argument '$1'"
                    echo "Usage: git commit-to <branch-name> [-m <commit-message>]"
                    return 1
                fi
                ;;
        esac
    done

    ##
    ## Validators
    ##

    # Check if branch name is provided
    if [[ -z "$NEW_BRANCH_NAME" ]]; then
        echo "Error: Missing branch name"
        echo "Usage: git commit-to <branch-name> [-m <commit-message>]"
        return 1
    fi

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Check if there are staged changes
    if git diff --staged --quiet; then
        echo "Error: No staged changes found. Use 'git add' to stage changes first."
        return 1
    fi
    
    ##
    ## Main Logic
    ##

    echo "Creating new branch '$NEW_BRANCH_NAME' from latest origin/$BASE_BRANCH..."

    # Fetch the latest changes from remote to ensure we have the latest base branch
    git fetch origin

    # Create a new branch at origin/BASE_BRANCH without switching to it
    git branch $NEW_BRANCH_NAME origin/$BASE_BRANCH

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create new branch from origin/master"
        return 1
    fi

    # Create a patch of the staged changes
    git diff --staged > /tmp/staged_changes.patch

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create patch of staged changes"
        git branch -D $NEW_BRANCH_NAME
        return 1
    fi

    echo "Applying staged changes to new branch and committing..."

    # Apply the patch to the index of the new branch without checking it out
    GIT_INDEX_FILE=".git/index.new" git read-tree $NEW_BRANCH_NAME
    GIT_INDEX_FILE=".git/index.new" git apply --cached /tmp/staged_changes.patch

    if [ $? -ne 0 ]; then
        echo "Error: Failed to apply staged changes to new branch"
        rm -f .git/index.new
        rm -f /tmp/staged_changes.patch
        git branch -D $NEW_BRANCH_NAME
        return 1
    fi

    # Write tree for the new index and get its hash
    NEW_TREE=$(GIT_INDEX_FILE=".git/index.new" git write-tree)

    # Create a commit on the new branch
    NEW_COMMIT=$(echo "$COMMIT_MESSAGE" | git commit-tree $NEW_TREE -p $NEW_BRANCH_NAME)

    # Update the new branch to point to this commit
    git update-ref "refs/heads/$NEW_BRANCH_NAME" $NEW_COMMIT

    echo "Pushing new branch to remote..."

    # Push the new branch to the remote
    git push -u origin $NEW_BRANCH_NAME

    # Clean up
    rm -f .git/index.new
    rm -f /tmp/staged_changes.patch

    echo "✅ Success! Staged changes have been committed to '$NEW_BRANCH_NAME' branch"
    echo "Current branch is still '$CURRENT_BRANCH'"
    echo "Branch '$NEW_BRANCH_NAME' has been pushed to origin"
    
    return 0
}

# If this script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_commit_staged_to "$@"
fi
